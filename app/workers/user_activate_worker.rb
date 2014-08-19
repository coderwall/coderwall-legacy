class UserActivateWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high

  def perform(user_id)
    user = User.find(user_id)
    return if user.active?

    RefreshUserJob.new.perform(user.id)
    NotifierMailer.welcome_email(user.username).deliver

    user.activate!
  end
end
