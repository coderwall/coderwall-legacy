class BuildActivityStream < Struct.new(:username)
  extend ResqueSupport::Basic

  @queue = 'MEDIUM'

  def perform
    user = User.find_by_username(username)
    user.build_repo_followed_activity!
  end
end