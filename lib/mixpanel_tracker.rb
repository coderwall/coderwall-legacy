module MixpanelTracker
  class TrackEventJob
    @queue = 'CRITICAL'
    class << self
      def mixpanel(ip)
        Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'], ip: ip)
      end

      def perform(name, params, request_ip)
        mixpanel(request_ip).track(name, params)
      end
    end
  end
end
