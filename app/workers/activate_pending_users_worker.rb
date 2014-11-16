class ActivatePendingUsersWorker
  include Sidekiq::Worker
  sidekiq_options queue: :user

  def perform
    # Spawning possibly many thousands
    # of workers the order doesn't really matter
    # but would like to spread their execution
    # over the next hour to avoid overloading
    # the database.
    User.pending.find_each(batch_size: 100) do |user|
      UserActivateWorker.perform_in(Random.rand(0..59).minutes, user.id)
    end
  end
end
