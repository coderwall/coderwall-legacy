class ActivatePendingUsersWorker
  include Sidekiq::Worker
  sidekiq_options queue: :critical


  def perform
    # Spawning possibly many thousands
    # of workers the order doesn't really matter
    # but would like to spread their execution
    # over the next hour to avoid overloading
    # the database.
    delay = 0
    User.pending.find_each(batch_size: 100) do |user|
      UserActivateWorker.perform_in(delay.minutes, user.id)
      delay = delay + Random.rand(0..59)
    end
  end
end
