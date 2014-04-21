namespace :twitter do
  task :fixids => :environment do
    User.where('twitter IS NOT NULL AND twitter_id IS NULL').find_each(:batch_size => 1000) do |user|
      if Rails.env.development?
        FixTwitter.new(user.username).perform
      else
        Resque.enqueue(FixTwitter, user.username)
      end
    end
  end

  task :buildbios => :environment do
    User.where("twitter_id IS NOT NULL").find_each(:batch_size => 1000) do |user|
      if Rails.env.development?
        BuildBioAndJoinedDates.new(user.username).perform
      else
        Resque.enqueue(BuildBioAndJoinedDates, user.username)
      end
    end
  end

  task :buildfollowers => :environment do
    User.where('twitter_id IS NOT NULL').find_each(:batch_size => 1000) do |user|
      if Rails.env.development?
        UpdateFollowers.new(user.username).perform
      else
        Resque.enqueue(UpdateFollowers, user.username)
      end
    end
  end

  task :build_follow_network => :environment do
    User.where('twitter_id IS NOT NULL').find_each(:batch_size => 1000) do |user|
      puts "PROCESSING #{user.username}"
      ids = REDIS.smembers(user.followers_key)
      User.where(:twitter_id => ids).each do |followed_user|
        user.follow(followed_user)
      end
    end
  end

  task :buildbioandjoineddates => :environment do
    User.active.find_each(:batch_size => 1000) do |user|
      if Rails.env.development?
        BuildBioAndJoinedDates.new(user.username).perform
      else
        Resque.enqueue(BuildBioAndJoinedDates, user.username)
      end
    end
  end

  task :activate => :environment do
    EarlyActivateTwitterers.new.perform
  end

  task :updates => :environment do
    User.stalest_twitter_profile(150).each do |user|
      user.async(:refresh_twitter!)
    end
  end

  task :build_links => :environment do
    User.active.find_each(:batch_size => 1000) do |user|
      user.async(:build_links!)
    end
  end

  task :test => :environment do
    user = User.with_username(ENV['username'])
    user.refresh_twitter!
  end

  task :links => :environment do
    links = {}
    puts "profiles: #{TwitterProfile.count}"
    TwitterProfile.all.each do |profile|
      puts "Scanning: #{profile.username}"
      tweet_links = []
      profile.tweets.each do |tweet|
        if tweet.created_at > 10.days.ago
          links_in_tweet = tweet.text.gsub(',', '').scan(/(https?:\/\/[\da-z\.-]+\.[a-z\.]{2,6}[\/\w \.-][^\s]+)/im)
          tweet_links << links_in_tweet.first.first unless links_in_tweet.empty?
        end
      end
      tweet_links.uniq.each do |url|
        (links[url] ||= []) << profile.username
      end
    end
    counter = 0
    list = []
    links.each do |key, value|
      counter = counter + 1
      list << [value.size, key]
    end
    list.sort { |x, y| x.first <=> y.first }.reverse.each do |item|
      puts "#{item.first}, #{item.last}"
    end
    puts "# LINKS: #{counter}"
  end
end