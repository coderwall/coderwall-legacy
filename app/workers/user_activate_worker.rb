class UserActivateWorker
  include Sidekiq::Worker
  sidekiq_options queue: :user

  def perform(user_id)
    user = User.find(user_id)
    return if user.active?

    begin
      NotifierMailer.welcome_email(user.id).deliver
      RefreshUserJob.new.perform(user.id)
      user.activate!

    rescue => e
      return if e.message == '550 5.1.3 Invalid address'
    end

  end
end
