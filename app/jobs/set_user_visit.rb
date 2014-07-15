class SetUserVisit < Struct.new(:username)
  extend ResqueSupport::Basic

  @queue = 'HIGH'

  def perform
    user = User.with_username(username)
    user.append_latest_visits(user.last_request_at || 2.years.ago)
    user.save(validate: false)
  end
end
