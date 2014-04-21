class BuildBioAndJoinedDates < Struct.new(:username)
  extend ResqueSupport::Basic

  @queue = 'HIGH'

  def perform
    user = User.with_username(username)
    unless user.github.blank? && user.joined_github_on.blank?
      user.joined_github_on = (user.send(:load_github_profile) || {})[:created_at]
    end

    unless user.twitter.blank?
      TwitterClient.perform_via_oauth(username) do
        begin
          puts user.twitter_id
          profile = Twitter.user(user.twitter)
          user.about = profile["description"] if user.about.blank?
          user.joined_twitter_on = profile["created_at"] if user.joined_twitter_on.blank?
        rescue Twitter::Error::Unauthorized
          puts "Invalid Token #{user.twitter} => #{user.twitter_id}"
        rescue Twitter::Error::NotFound => ex
          puts "Unable to find #{user.twitter_id}"
        end
      end
    end

    user.save! if user.changed?
  end

end