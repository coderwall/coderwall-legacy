class BuildActivityStreamJob
  include Sidekiq::Worker

  sidekiq_options queue: :medium

  def perform(username)
    user = User.find_by_username(username)
    user.build_repo_followed_activity!
  end
end