class GenerateEvent < Struct.new(:event_type, :audience, :data, :drip_rate)
  extend ResqueSupport::Basic

  @queue = 'HIGH'

  def perform
    if event_still_valid?(event_type, data)
      Event.generate_event(event_type, audience.with_indifferent_access, data.with_indifferent_access, drip_rate)
    end
  end

  def event_still_valid?(event_type, data)
    if event_type.to_sym == :new_protip
      Protip.where(public_id: (data[:public_id] || data['public_id'])).exists?
    else
      true
    end
  end
end