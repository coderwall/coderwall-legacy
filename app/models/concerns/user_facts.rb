module UserFacts
  extend ActiveSupport::Concern

  included do
    def build_facts
      build_github_facts
      build_lanyrd_facts
      build_linkedin_facts
      build_bitbucket_facts
      build_speakerdeck_facts
      build_slideshare_facts
    end

    def build_generic_facts(thing_name, can_skip)
      Rails.logger.info("[FACTS] Building #{thing_name} facts for #{username}")
      begin
        if can_skip
          yield if block_given?
          Rails.logger.info("[FACTS] Processed #{thing_name} facts for #{username}")
        else
          Rails.logger.info("[FACTS] Skipped #{thing_name} facts for #{username}")
        end
      rescue => ex
        Rails.logger.error("[FACTS] Unable to build #{thing_name} facts due to '#{ex}' >>\n#{ex.backtrace.join("\n  ")}")
      end
    end

    def build_speakerdeck_facts
      build_generic_facts('SpeakerDeck', speakerdeck_identity) do
        Speakerdeck.new(speakerdeck).facts
      end
    end

    def build_slideshare_facts
      build_generic_facts('SlideShare', slideshare_identity) do
        Slideshare.new(slideshare).facts
      end
    end

    def build_lanyrd_facts
      build_generic_facts('Lanyrd', lanyrd_identity) do
        Lanyrd.new(twitter).facts
      end
    end

    def build_bitbucket_facts
      build_generic_facts('Bitbucket', lanyrd_identity) do
        Bitbucket::V1.new(bitbucket).update_facts!
      end
    end

    def build_github_facts
      build_generic_facts('GitHub', (github_identity && github_failures == 0)) do
        GithubProfile.for_username(github).facts
      end
    end

    def build_linkedin_facts
      build_generic_facts('LinkedIn', lanyrd_identity) do
        LinkedInStream.new(linkedin_token + '::' + linkedin_secret).facts
      end
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
