class ProtipsRecalculateScoresJob
  include Sidekiq::Worker

  sidekiq_options queue: :protip

  def perform
    Protip.where('created_at > ?', 25.hours.ago).where(upvotes_value_cache: nil).each do |protip|
      ProcessProtipJob.perform_async(:recalculate_score, protip.id)
    end
  end
end
