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
      Rails.logger.info("[FACTS] Building SpeakerDeck facts for #{username}")
      begin
        if speakerdeck_identity
          Speakerdeck.new(speakerdeck).facts
          Rails.logger.info("[FACTS] Processed SpeakerDeck facts for #{username}")
        else
          Rails.logger.info("[FACTS] Skipped SpeakerDeck facts for #{username}")
        end
      rescue => ex
        Rails.logger.error("[FACTS] Unable to build SpeakerDeck facts due to '#{ex}' >>\n#{ex.backtrace.join("\n  ")}")
      end
    end

    def build_slideshare_facts
      Rails.logger.info("[FACTS] Building SlideShare facts for #{username}")
      begin
        if slideshare_identity
          Slideshare.new(slideshare).facts
          Rails.logger.info("[FACTS] Processed Slideshare facts for #{username}")
        else
          Rails.logger.info("[FACTS] Skipped SlideShare facts for #{username}")
        end
      rescue => ex
        Rails.logger.error("[FACTS] Unable to build SlideShare facts due to '#{ex}' >>\n#{ex.backtrace.join("\n  ")}")
      end
    end

    def build_lanyrd_facts
      Rails.logger.info("[FACTS] Building Lanyrd facts for #{username}")
      begin
        if lanyrd_identity
          Lanyrd.new(twitter).facts
          Rails.logger.info("[FACTS] Processed Lanyrd facts for #{username}")
        else
          Rails.logger.info("[FACTS] Skipped Lanyrd facts for #{username}")
        end
      rescue => ex
        Rails.logger.error("[FACTS] Unable to build Lanyrd facts due to '#{ex}' >>\n#{ex.backtrace.join("\n  ")}")
      end
    end

    def build_bitbucket_facts
      Rails.logger.info("[FACTS] Building Bitbucket facts for #{username}")
      begin
        unless bitbucket.blank?
          Bitbucket::V1.new(bitbucket).update_facts!
          Rails.logger.info("[FACTS] Processed Bitbucket facts for #{username}")
        else
          Rails.logger.info("[FACTS] Skipped Bitbucket facts for #{username}")
        end
      rescue => ex
        Rails.logger.error("[FACTS] Unable to build Bitbucket facts due to '#{ex}' >>\n#{ex.backtrace.join("\n  ")}")
      end
    end

    def build_github_facts(since=Time.at(0))
      Rails.logger.info("[FACTS] Building GitHub facts for #{username}")
      begin
        if github_identity && github_failures == 0
          GithubProfile.for_username(github, since).facts
          Rails.logger.info("[FACTS] Processed GitHub facts for #{username}")
        else
          Rails.logger.info("[FACTS] Skipped GitHub facts for #{username}")
        end
      rescue => ex
        Rails.logger.error("[FACTS] Unable to build GitHub facts due to '#{ex}' >>\n#{ex.backtrace.join("\n  ")}")
      end
    end

    def build_linkedin_facts
      Rails.logger.info("[FACTS] Building LinkedIn facts for #{username}")
      begin
        if linkedin_identity
          LinkedInStream.new(linkedin_token + '::' + linkedin_secret).facts
          Rails.logger.info("[FACTS] Processed LinkedIn facts for #{username}")
        else
          Rails.logger.info("[FACTS] Skipped LinkedIn facts for #{username}")
        end
      rescue => ex
        Rails.logger.error("[FACTS] Unable to build LinkedIn facts due to '#{ex}' >>\n#{ex.backtrace.join("\n  ")}")
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
