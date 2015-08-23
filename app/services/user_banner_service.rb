class UserBannerService
  def self.ban(user)
    user.update_attribute(:banned_at, Time.now.utc)
    UserProtipsService.deindex_all_for(user)
    UserCommentsService.deindex_all_for(user)
  end

  def self.unban(user)
    user.update_attribute(:banned_at, nil)
    UserProtipsService.reindex_all_for(user)
  end
end
