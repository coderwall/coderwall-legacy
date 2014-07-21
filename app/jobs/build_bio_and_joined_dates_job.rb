class BuildBioAndJoinedDatesJob
  include Sidekiq::Worker

  sidekiq_options queue: :high

  def perform(username)
    user = User.find_by_username(username)
    unless user.github.blank? && user.joined_github_on.blank?
      user.joined_github_on = (user.send(:load_github_profile) || {})[:created_at]
    end

    user.save! if user.changed?
  end

end
