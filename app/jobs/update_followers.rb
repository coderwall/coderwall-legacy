class UpdateFollowers < Struct.new(:username)
  extend ResqueSupport::Basic

  @queue = 'REFRESH'

  def perform
    user = User.with_username(username)
    return if user.last_refresh_at < 3.days.ago
    TwitterClient.perform_via_oauth(username) do
      begin
        user.build_follow_list!
        puts "Updated followers for #{user.twitter}"
      rescue Twitter::Error::Unauthorized
        puts "Invalid Token #{user.twitter} => #{user.twitter_id}"
      rescue Twitter::Error::NotFound => ex
        raise user.twitter_id
      end
    end
  end

end