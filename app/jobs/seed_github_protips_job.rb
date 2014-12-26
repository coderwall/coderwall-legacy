class SeedGithubProtipsJob
  include Sidekiq::Worker

  sidekiq_options queue: :github

  def perform(username)
    user = User.find_by_username(username)
    user.build_github_proptips_fast
  end
end
