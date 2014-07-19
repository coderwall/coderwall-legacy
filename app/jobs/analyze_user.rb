class AnalyzeUser < Struct.new(:username)
  extend ResqueSupport::Basic

  @queue = 'HIGH'

  def perform
    user = User.find_by_username(username)
    unless user.twitter.nil?
      RestClient.get "#{ENV['TWITTER_ANALYZER_URL']}/#{user.username}/#{user.twitter}"
    end
  end
end