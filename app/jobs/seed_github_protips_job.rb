class SeedGithubProtipsJob
  include Sidekiq::Worker

  sidekiq_options queue: :low

  def perform(username)
    user = User.find_by_username(username)
    user.build_github_proptips_fast
  end
end
