class ProcessProtip < Struct.new(:process_type, :protip_id)
  extend ResqueSupport::Basic

  @queue = 'LOW'

  def perform
    protip = Protip.find(protip_id)
    case process_type.to_sym
      when :recalculate_score
        protip.update_score!(true)
      when :resave
        protip.save
      when :delete
        protip.destroy
      when :cache_score
        protip.upvotes_value = protip.upvotes_value(true)
        protip.save(validate: false)
    end
  end
end
