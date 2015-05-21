class UserActivateWorker
  include Sidekiq::Worker
  sidekiq_options queue: :user

  def perform(user_id)
    begin
      user = User.find(user_id)
      return if user.active?

      begin
        NotifierMailer.welcome_email(user.id).deliver
        RefreshUserJob.new.perform(user.id)
        user.activate!

      rescue => e
        #User provided corrupted email, we can't email.
        if e.message == '550 5.1.3 Invalid address'
          user.destroy
          return
        else
          raise e
        end

      end
    rescue ActiveRecord::RecordNotFound
      return
    end
  end
end
