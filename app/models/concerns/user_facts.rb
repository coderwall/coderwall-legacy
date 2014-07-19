module UserFacts
  extend ActiveSupport::Concern
  included do
    def build_facts(all)
      since = (all ? Time.at(0) : self.last_refresh_at)
      build_github_facts(since)
      build_lanyrd_facts
      build_linkedin_facts
      build_bitbucket_facts
      build_speakerdeck_facts
      build_slideshare_facts
    end

    def build_speakerdeck_facts
      Speakerdeck.new(speakerdeck).facts if speakerdeck_identity
    end

    def build_slideshare_facts
      Slideshare.new(slideshare).facts if slideshare_identity
    end

    def build_lanyrd_facts
      Lanyrd.new(twitter).facts if lanyrd_identity
    end

    def build_bitbucket_facts
      Bitbucket::V1.new(bitbucket).update_facts! unless bitbucket.blank?
    end

    def build_github_facts(since=Time.at(0))
      GithubProfile.for_username(github, since).facts if github_identity and github_failures == 0
    end

    def build_linkedin_facts
      LinkedInStream.new(linkedin_token + '::' + linkedin_secret).facts if linkedin_identity
    rescue => e
      logger.error(e.message + "\n  " + e.backtrace.join("\n  "))
    end


    def repo_facts
      self.facts.select { |fact| fact.tagged?('personal', 'repo', 'original') }
    end

    def lanyrd_facts
      self.facts.select { |fact| fact.tagged?('lanyrd') }
    end

    #Let put these here for now
    def bitbucket_identity
      "bitbucket:#{bitbucket}" unless bitbucket.blank?
    end

    def speakerdeck_identity
      "speakerdeck:#{speakerdeck}" if speakerdeck
    end

    def slideshare_identity
      "slideshare:#{slideshare}" if slideshare
    end

  end
end