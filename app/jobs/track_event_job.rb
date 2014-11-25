class TrackEventJob
  include Sidekiq::Worker

  sidekiq_options queue: :event_tracker

  def perform(name, params, request_ip)
    mixpanel(request_ip).track(name, params)
  end

  def mixpanel(ip)
    Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'], ip: ip)
  end
end
