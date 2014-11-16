class AwardJob
  include Sidekiq::Worker
  include Awards

  sidekiq_options queue: :user

  def perform(badge, date, provider, candidate)
    award(badge.constantize, date, provider, candidate)
  end
end
