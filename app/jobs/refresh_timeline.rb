class RefreshTimeline < Struct.new(:username)
  extend ResqueSupport::Basic

  @queue = 'MEDIUM'

  def perform
    user = User.find_by_username(username)
    Event.create_timeline_for(user)
  end
end
