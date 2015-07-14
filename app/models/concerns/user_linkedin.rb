module UserLinkedin
  extend ActiveSupport::Concern

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
