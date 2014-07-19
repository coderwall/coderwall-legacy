module UserLinkedin
  extend ActiveSupport::Concern

  included do
    def linkedin_identity
      "linkedin:#{linkedin_token}::#{linkedin_secret}" if linkedin_token
    end

    def clear_linkedin!
      self.linkedin            = nil
      self.linkedin_id         = nil
      self.linkedin_token      = nil
      self.linkedin_secret     = nil
      self.linkedin_public_url = nil
      self.linkedin_legacy     = nil
      save!
    end
  end
end