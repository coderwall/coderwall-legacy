#TODO SPECS
class GenerateEventJob
  include Sidekiq::Worker

  sidekiq_options queue: :event_publisher

  def perform(event_type, audience, data, drip_rate=:immediately)
    return
    data = HashWithIndifferentAccess.new(data)
    audience = HashWithIndifferentAccess.new(audience)
    if event_still_valid?(event_type, data)
      Event.generate_event(event_type, audience, data, drip_rate)
    end
  end

  private

  def event_still_valid?(event_type, data)
    if event_type.to_sym == :new_protip
      #TODO check state instead
      Protip.where(public_id: data[:public_id]).exists?
    else
      true
    end
  end
end
