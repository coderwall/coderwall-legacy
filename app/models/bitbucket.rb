require_dependency 'factual'
require_dependency 'repository'

class Bitbucket
  include Factual
  acts_as_factual
  NAME = "bitbucket"

  class V1 < Bitbucket

    PROTOCOL = "https"
    API_URL  = "api.bitbucket.org/1.0"
    WEB_URL  = "bitbucket.org"

    class Repo
      include Factual
      include Repository
      ##########################################
      # acts_as_repository interface implementation
      ##########################################
      acts_as_a_repository
      acts_as_factual

      attr_accessor :repo, :username

      def initialize(repository_hash, username)
        super()
        @repo     = repository_hash
        @username = username
        update_tags!
      end

      def provider
        NAME
      end

      def name
        repo[:name]
      end

      def description
        repo[:description]
      end

      def repo_type
        'personal'
      end

      def size
        repo[:size]
      end

      def followers
        repo[:followers].collect { |follower| follower[:username] }
      end

      def forks
        repo[:forks]
      end

      def forked?
        repo[:is_fork] == true
      end

      def languages_with_percentage
        @languages ||= repo[:language].split(",").map { |language| { language.camelize => 100.0 } }.reduce(&:merge!) || {}
        #TODO: if no language, try to discover it from wiki, code, etc
      end

      def contributions_of(user_credentials)
        repo[:commits].collect { |commit| commit[:user][:username] == user_credentials }.count
      end

      def contributions
        repo[:commits].count
      end

      def raw_readme
        repo[:readme] ? repo[:readme][:data] : nil
      end

      #factual interface
      def fact_identity
        "#{repo[:html_url]}:#{username}"
      end

      def fact_owner
        "#{NAME}:#{username}"
      end

      def fact_name
        name
      end

      def fact_date
        repo[:created_on]
      end

      def fact_url
        "#{repo[:html_url]}"
      end

      def fact_tags
        tags
      end

      def fact_meta_data
        {
          languages:    languages_that_meet_threshold,
          original:     original?,
          times_forked: forks,
          watchers:     followers,
          website:      repo[:website].blank? ? nil : repo[:website]
        }
      end

    end

    def initialize(username, password=nil)
      @username = username.to_s.strip
      @password = password
      @data     = get_all
      @repos    = []
      @data[:repositories].each do |repository|
        repo = Repo.new(repository, @data[:user][:username])
        @repos << repo if repo.significant?
      end unless @data.blank?
    end

    def repos
      @repos
    end

    #factual interface
    def facts
      return [] if @username.blank?
      repo_facts + user_facts
    end

    def repo_facts()
      @repos.reduce([]) { |facts, repo| facts + repo.facts }
    end

    def user_facts
      @data[:user].nil? ? [] : default_facts
    end

    def fact_identity
      "#{NAME}:#{@username}"
    end

    def fact_owner
      fact_identity
    end

    def fact_name
      "Joined #{NAME.camelize}"
    end

    def fact_date
      @data[:user] && Time.parse(@data[:user][:joined])
    end

    def fact_url
      "#{web_address}/#{@username}"
    end

    def fact_tags
      [NAME, "account-created"]
    end

    def fact_meta_data
      {
        avatar_url: @data[:user][:avatar],
        followers:  @data[:user][:followers].collect { |follower| follower[:username] }
      } unless @data[:user].nil?
    end

    def get_all
      repositories = get_user_repositories
      if (repositories[:user] and repositories[:repositories])
        @username                       = repositories[:user][:username] #the get repositiories accepts emails but the rest of the API calls do not
        repositories[:user][:followers] = get_user_followers #add user followers to user hash
        repositories[:user][:joined]    = get_user_join_date

        repositories[:repositories].each do |repository|
          repository[:followers] = get_repository_followers(repository[:slug]) #add repo followers to repo hash
          repository[:commits]   = get_repository_commits(repository[:slug])
          repository[:readme]    = get_repository_readme(repository[:slug])
          repository[:forks]     = get_repository_forks(repository[:slug])
          repository[:html_url]  = get_repository_web_url(repository[:slug])
        end
        repositories
      else
        {}
      end
    end

    def web_address
      "#{PROTOCOL}://#{WEB_URL}"
    end

    def get_repository_web_url(repo_slug)
      "#{web_address}/#{@username}/#{repo_slug}/overview"
    end

    def get_repository_forks(repo_slug)
      get(build_uri("repositories/#{@username}/#{repo_slug}"))[:forks_count]
    end

    def get_repository_readme(repo_slug)
      get(build_uri("repositories/#{@username}/#{repo_slug}/src/tip/README.rst"))
    end

    def get_repository_commits(repo_slug)
      commits = get(build_uri("repositories/#{@username}/#{repo_slug}/events?type=commit&limit=50&start=0"))
      count   = commits[:count]
      start   = 50

      until start > count do
        commit_batch = get(build_uri("repositories/#{@username}/#{repo_slug}/events?type=commit&limit=50&start=#{start}"))
        commits[:events].concat(commit_batch[:events])
        start += 50
      end
      commits
    end

    def get_user_repositories
      get(build_uri("users/#{@username}"))
    end

    def get_user_followers
      get(build_uri("users/#{@username}/followers"))[:followers]
    end

    def get_user_join_date
      RestClient.get("#{web_address}/#{@username}").match(/time datetime="([\d\-T:\.\+]+)"/) && $1
    end

    def get_repository_followers(repo_slug)
      get(build_uri("repositories/#{@username}/#{repo_slug}/followers"))[:followers]
    end

    #their uris are not symmetric, they're actually pretty bad. hopefully they'll fix it in the future so only one path
    #is needed
    protected
    def build_uri(path)
      url = "#{PROTOCOL}://"
      if @password
        url += "#{@username}:#{@password}@"
      end
      url += "#{API_URL}/#{path}"
      RestClient::Resource.new(url, verify_ssl: OpenSSL::SSL::VERIFY_NONE).url
      #URI.parse(url)
    end

    protected
    def get(uri)
      begin
        response = RestClient.get uri

        JSON.parse(response).with_indifferent_access
      rescue Exception => e
        Rails.logger.error "Bitbucket-Error@#{@username}:#{uri}#{e.message}"
        {}
      end
    end
  end
end