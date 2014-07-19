class SeedGithubProtips < Struct.new(:username)
  extend ResqueSupport::Basic

  @queue = 'LOWER'

  def perform
    user = User.find_by_username(username)
    user.build_github_proptips_fast
  end
end
