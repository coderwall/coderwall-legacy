class AwardJob
  include Sidekiq::Worker

  sidekiq_options queue: :high

  def perform(badge, date, provider, candidate)
    award(badge.constantize, date, provider, candidate)
  end

  def award(badge, date, provider, candidate)
    RestClient.post(
      award_badge_url(
        only_path: false,
        host: Rails.application.config.host,
        protocol: (Rails.application.config.force_ssl ? 'https' : 'http')
      ),
      badge: badge,
      date: date,
      provider.to_sym => candidate,
      api_key: ENV['ADMIN_API_KEY']
    )
  end
end
