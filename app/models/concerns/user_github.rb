module UserGithub
  extend ActiveSupport::Concern

  included do

    def github_identity
      "github:#{github}" if github
    end

    def clear_github!
      self.github_id        = nil
      self.github           = nil
      self.github_token     = nil
      self.joined_github_on = nil
      self.github_failures  = 0
      save!
    end
  end

  module ClassMethods
    def stalest_github_profile(limit = nil)
      query = active.order("achievements_checked_at ASC")
      limit ? query.limit(limit) : query
    end
  end
end