class ClearExpiredSessionsJob
  include Sidekiq::Worker

  sidekiq_options queue: :data_cleanup

  def perform
    ActiveRecord::SessionStore::Session.delete_all(["updated_at < ?", 7.days.ago])
  end
end
