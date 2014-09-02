class BuildActivityStreamJob
  include Sidekiq::Worker

  sidekiq_options queue: :medium

  def perform(username)
    user = User.with_username(username)
    user.build_repo_followed_activity!
  end
end
