module AuthorDetails
  extend ActiveSupport::Concern

  included do
    before_save do
      self.user_name = user.name
      self.user_email = user.email
      self.user_agent = user.last_ua
      self.user_ip = user.last_ip
    end
  end

end