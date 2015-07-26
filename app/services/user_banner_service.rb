class UserBannerService
  def self.ban(user)
    user.update_attribute(:banned_at, Time.now.utc)
    DeindexUserProtipsService.run(user)
  end

  def self.unban(user)
    user.update_attribute(:banned_at, nil)
    IndexUserProtipsService.run(user)
  end
end
