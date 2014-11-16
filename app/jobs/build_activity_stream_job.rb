class BuildActivityStreamJob
  include Sidekiq::Worker

  sidekiq_options queue: :timeline

  def perform(username)
    user = User.with_username(username)
    user.build_repo_followed_activity!
  end
end
