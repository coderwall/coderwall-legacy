class AnalyzeUserJob
  include Sidekiq::Worker

  sidekiq_options queue: :high

  def perform(username)
    user = User.find_by_username(username)
    unless user.twitter.nil?
      RestClient.get "#{ENV['TWITTER_ANALYZER_URL']}/#{user.username}/#{user.twitter}"
    end
  end
end