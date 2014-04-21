class TwitterClient
  class OverCapacityError < StandardError
  end

  class ExceededRateLimit < StandardError
  end

  class UserNotFound < StandardError
  end

  class UserIsNotPublic < StandardError
  end

  TWITTER_CONSUMER_KEY = ENV['TWITTER_CONSUMER_KEY']
  TWITTER_CONSUMER_SECRET = ENV['TWITTER_CONSUMER_SECRET']
  TWITTER_REDIRECT_URL = ENV['TWITTER_REDIRECT_URL']
  TWITTER_OAUTH_TOKEN = ENV['TWITTER_OAUTH_TOKEN']
  TWITTER_OAUTH_SECRET = ENV['TWITTER_OAUTH_SECRET']

  class << self
    def next_token!
      REDIS.LPOP('twitter:tokens')
    end

    def configure_twitter!(username)
      user = User.with_username(username)
      Twitter.configure do |config|
        config.consumer_key = TWITTER_CONSUMER_KEY
        config.consumer_secret = TWITTER_CONSUMER_SECRET
        config.oauth_token = user.twitter_token
        config.oauth_token_secret = user.twitter_secret
      end
    end

    def perform_via_oauth(username, continue_if_invalid = false)
      TwitterClient.configure_twitter!(username)
      times = 0
      begin
        times = times + 1
        yield
        times = 0
      rescue Twitter::Error::ServiceUnavailable
        puts 'Twitter Unavailable'
        sleep(5)
        retry if times < 3
      rescue Twitter::Error::Unauthorized => ex
        if continue_if_invalid
          puts 'Invalid Token'
          TwitterClient.next_token!
          TwitterClient.configure_twitter!(username)
          retry if times < 3
        else
          raise ex
        end
      rescue Twitter::Error::BadRequest
        puts 'Rate limit exceeded, retrying'
        TwitterClient.next_token!
        TwitterClient.configure_twitter!(username)
        retry if times < 3
      end
    end

    def timeline_for(username, since=nil)
      attempts = 0
      begin
        attempts =+1
        options = {
            screen_name: username.strip,
            count: 200,
            trim_user: true
        }
        options[:since_id] = since if since
        params = options.collect { |k, v| "#{k}=#{v}" }.join('&')
        return api_request("https://api.twitter.com/1/statuses/user_timeline.json?#{params}")
      rescue RestClient::BadRequest => ex
        raise ExceededRateLimit if ex.response.headers[:x_ratelimit_remaining] == 0 || ex.message.include?('Rate limit exceeded')
        throw "BadRequest => #{ex.message}, #{ex.response}"
      rescue RestClient::Forbidden => ex
        throw "Forbidden => #{ex.message}, #{ex.response}"
      rescue RestClient::Unauthorized
        raise UserIsNotPublic
      rescue RestClient::ResourceNotFound
        raise UserNotFound
      rescue RestClient::BadGateway, RestClient::ServiceUnavailable
        if attempts < 3
          Rails.logger.error("Twitter over capacity, retrying for #{username}")
          sleep(2)
          retry
        else
          raise OverCapacityError
        end
      ensure
        RestClient.before_execution_procs.clear
      end
    end

    def client
      @client ||= begin
        Grackle::Client.new(auth: {
            type: :oauth,
            consumer_key: TWITTER_CONSUMER_KEY, consumer_secret: TWITTER_CONSUMER_SECRET,
            token: TWITTER_OAUTH_TOKEN, token_secret: TWITTER_OAUTH_SECRET
        })
      end
    end

    def find_user(tweet)
      User.where(twitter: tweet.first).first || begin
        puts "#{tweet.first}: #{tweet.last}"
        match = tweet.last.match(/coderwall.com\/([\w]*)/)
        if match
          puts "Twitter: found profile url #{match[1]}"
          return User.with_username(match[1])
        else
          url = expand_short_url(tweet)
          if url
            match = url.match(/coderwall.com\/([\w]*)/)
            if match
              puts "Twitter: expanded url and found #{match[1]}"
              return User.with_username(match[1])
            else
              puts "Twitter: could no expand url #{url}"
              return nil
            end
          else
            puts "Twitter: could not find user in '#{tweet.inspect}'"
            return nil
          end
        end
      end
    end

    def expand_short_url(tweet)
      match = tweet.last.match(/(http:\/\/t.co\/[\w]*)/)
      if match
        r = Net::HTTP.get_response(URI.parse(match[1]))
        expanded = r['location']
        expanded
      else
        nil
      end
    end

    def collect_url_mentions
      tweets = []
      response = api_request("http://search.twitter.com/search.json?q=#{CGI.escape('coderwall.com')}&rpp=100&result_type=recent")
      response['results'].each do |tweet|
        tweets << [tweet['from_user'], tweet['text']]
      end
      tweets
    rescue Exception => ex
      Rails.logger.error("Twitter: Search for coderwall.com failed due to #{ex.message}")
      return nil
    end

    def collect_name_mentions
      tweets = []
      response = api_request('http://api.twitter.com/1/statuses/mentions.json?count=200')
      response.each do |tweet|
        tweets << [tweet['user']['screen_name'], tweet['text']]
      end
      tweets
    end

    def api_request(url)
      RestClient.add_before_execution_proc do |req, _|
        consumer = OAuth::Consumer.new(TwitterClient::TWITTER_CONSUMER_KEY, TwitterClient::TWITTER_CONSUMER_SECRET, {
            site: 'http://api.twitter.com',
            scheme: :header
        })
        access_token = OAuth::AccessToken.new(consumer, TwitterClient::TWITTER_OAUTH_TOKEN, TwitterClient::TWITTER_OAUTH_SECRET)
        consumer.sign!(req, access_token)
      end
      results = RestClient.get(url)
      Rails.logger.info "Twitter: #{results.headers[:x_ratelimit_remaining]} requests remaining out of #{results.headers[:x_ratelimit_limit]}" if results.headers[:x_ratelimit_remaining]
      JSON.parse(results)
    end
  end
end
