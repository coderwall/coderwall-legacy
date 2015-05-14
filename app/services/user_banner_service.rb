class UserBannerService
  def self.ban(user)
    user.update_attribute(:banned_at, Time.now.utc)
  end

  def self.unban(user)
    user.update_attribute(:banned_at, nil)
  end
end
