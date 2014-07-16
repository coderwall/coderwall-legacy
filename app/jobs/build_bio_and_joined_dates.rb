class BuildBioAndJoinedDates < Struct.new(:username)
  extend ResqueSupport::Basic

  @queue = 'HIGH'

  def perform
    user = User.with_username(username)
    unless user.github.blank? && user.joined_github_on.blank?
      user.joined_github_on = (user.send(:load_github_profile) || {})[:created_at]
    end

    user.save! if user.changed?
  end

end
