class ActivatePendingUsersWorker
  include Sidekiq::Worker
  sidekiq_options queue: :critical

  def perform
    User.pending.find_each(batch_size: 50) do |user|
      ActivateUserJob.perform_async(user.username, always_activate = false)
    end
  end
end
