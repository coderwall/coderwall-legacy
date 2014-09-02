class SeedGithubProtipsJob
  include Sidekiq::Worker

  sidekiq_options queue: :low

  def perform(username)
    user = User.with_username(username)
    user.build_github_proptips_fast
  end
end
