class EarlyActivateTwitterers
  extend ResqueSupport::Basic

  @queue = 'HIGH'

  def perform
    tweets = TwitterClient.collect_name_mentions
    tweets += TwitterClient.collect_url_mentions

    tweets.each do |tweet|
      if user = TwitterClient.find_user(tweet)
        if user && user.pending?
          Rails.logger.info "Activating user early: #{user.username}"
          Resque.enqueue(ActivateUser, user.username)
        end
      end
    end
  end
end