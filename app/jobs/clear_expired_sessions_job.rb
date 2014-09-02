class ClearExpiredSessionsJob
  include Sidekiq::Worker

  sidekiq_options queue: :low

  def perform
    ActiveRecord::SessionStore::Session.delete_all(["updated_at < ?", 7.days.ago])
  end
end
