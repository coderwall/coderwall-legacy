class ActivateUserJob
  include Sidekiq::Worker
  sidekiq_options queue: :high

  def perform(username, always_activate=true)
    user = User.find_by_username(username)
    return if user.active? || always_activate
    RefreshUserJob.new.perform(username)
    unless user.badges.empty?
      user.activate!
      NotifierMailer.welcome_email(username).deliver
    end
  end
end