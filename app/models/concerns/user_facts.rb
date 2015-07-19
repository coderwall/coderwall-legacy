module UserFacts
  extend ActiveSupport::Concern

  def build_facts(all=true)
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
      if github_profile.present?
        github_profile.update_facts!
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

  def facts
    @facts ||= begin
      user_identites = [linkedin_identity, bitbucket_identity, lanyrd_identity, twitter_identity, github_identity, speakerdeck_identity, slideshare_identity, id.to_s].compact
      Fact.where(owner: user_identites.collect(&:downcase)).all
    end
  end

  def times_spoken
    facts.select { |fact| fact.tagged?("event", "spoke") }.count
  end

  def times_attended
    facts.select { |fact| fact.tagged?("event", "attended") }.count
  end


  def add_skills_for_unbadgified_facts
    add_skills_for_repo_facts!
    add_skills_for_lanyrd_facts!
  end

  def add_skills_for_repo_facts!
    repo_facts.each do |fact|
      fact.metadata[:languages].try(:each) do |language|
        unless self.deleted_skill?(language)
          skill = add_skill(language)
          skill.save
        end
      end unless fact.metadata[:languages].nil?
    end
  end

  def add_skills_for_lanyrd_facts!
    tokenized_lanyrd_tags.each do |lanyrd_tag|
      if self.skills.any?
        skill = skill_for(lanyrd_tag)
        skill.apply_facts unless skill.nil?
      else
        skill = add_skill(lanyrd_tag)
      end
      skill.save unless skill.nil?
    end
  end
end
