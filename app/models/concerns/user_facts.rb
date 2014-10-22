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

    def build_generic_facts(thing_name, can_skip, identity)
      Rails.logger.info("[FACTS] Building #{thing_name} facts for #{username} (identity: '#{identity}', can_skip: #{can_skip}}")
      begin
        if identity
          yield if block_given?

          Rails.logger.info("[FACTS] Processed #{thing_name} facts for #{username}")
        else
          Rails.logger.info("[FACTS] Skipped #{thing_name} facts for #{username}")
        end
      rescue => ex
        Rails.logger.error("[FACTS] Unable to build #{thing_name} facts due to '#{ex}' >>\n#{ex.backtrace.join("\n  ")}")
      end
    end

    def build_github_facts
      build_generic_facts('GitHub', (github_identity.present? && github_failures == 0), github_identity) do
        GithubProfile.for_username(identity).facts
      end
    end

    def build_speakerdeck_facts
      build_generic_facts('SpeakerDeck', (speakerdeck_identity.present?), speakerdeck_identity) do
        Speakerdeck.new(identity).facts
      end
    end

    def build_slideshare_facts
      build_generic_facts('SlideShare', (slideshare_identity.present?), slideshare_identity) do
        Slideshare.new(identity).facts
      end
    end

    def build_lanyrd_facts
      build_generic_facts('Lanyrd', (lanyrd_identity.present?), lanyrd_identity) do
        Lanyrd.new(identity).facts
      end
    end

    def build_bitbucket_facts
      build_generic_facts('Bitbucket', (bitbucket_identity.present?), bitbucket_identity) do
        Bitbucket::V1.new(identity).update_facts!
      end
    end

    def build_linkedin_facts
      build_generic_facts('LinkedIn', (linkedin_identity.present?), linkedin_identity) do
        LinkedInStream.new(identity + '::' + linkedin_secret).facts
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

    # Duplicated in app/models/concerns/user_github.rb
    def github_identity
      "github:#{github}" if github
    end

    # Duplicated in app/models/concerns/user_linkedin.rb
    def linkedin_identity
      "linkedin:#{linkedin_token}::#{linkedin_secret}" if linkedin_token
    end
  end
end
