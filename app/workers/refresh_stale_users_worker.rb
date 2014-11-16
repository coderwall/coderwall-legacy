class RefreshStaleUsersWorker
  include Sidekiq::Worker
  sidekiq_options queue: :user

  def perform
    user_records.find_each(batch_size: 1000) do |user|
      RefreshUserJob.perform_in(minutes, user.id)
    end
  end

  def minutes
    # spread the execution of the spawned jobs across the next 24 hours
    Random.rand(0..1439).minutes
  end

  def user_records
    User.
      active.
      where('last_refresh_at < ?', 5.days.ago).
      order('last_refresh_at ASC').
      select(:id)
  end
end
