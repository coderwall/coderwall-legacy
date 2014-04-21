class FixTwitter < Struct.new(:username)
  extend ResqueSupport::Basic

  @queue = 'LOW'

  def perform
    user = User.with_username(username)
    TwitterClient.perform_via_oauth(username, contine_if_invalid = true) do
      begin
        results = Twitter.users(user.twitter).first
        if results
          user.update_attribute(:twitter_id, results['id'])
          puts "Twitter: updated #{user.twitter} to #{user.twitter_id}"
        end
      rescue Twitter::Error::NotFound => ex
        puts "Twitter: #{user.twitter} is no longer valid"
        user.clear_twitter!
      rescue ActiveRecord::RecordNotUnique
        puts "Found a duplicate user => #{user.username}"
      end
    end
  end
end