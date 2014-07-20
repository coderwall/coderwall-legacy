class SeedGithubProtips < Struct.new(:username)
  extend ResqueSupport::Basic

  @queue = 'LOWER'

  def perform
    user = User.with_username(username)
    user.build_github_proptips_fast
  end
end
