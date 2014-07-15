class RefreshTimeline < Struct.new(:username)
  extend ResqueSupport::Basic

  @queue = 'MEDIUM'

  def perform
    user = User.with_username(username)
    Event.create_timeline_for(user)
    Rails.logger.debug("Refreshed timeline #{username}")
  end
end
