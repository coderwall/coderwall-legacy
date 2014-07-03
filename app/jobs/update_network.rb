class UpdateNetwork < Struct.new(:update_type, :public_id, :data)
  extend ResqueSupport::Basic

  @queue = 'HIGH'

  def perform
    protip = Protip.with_public_id(public_id)
    unless protip.nil?
      case update_type.to_sym
        when :new_protip
          protip.networks.each do |network|
            network.protips_count_cache += 1
            network.save(validate: false)
          end
        when :protip_upvote
          protip.networks.each do |network|
            network.save
          end
      end
    end
  end
end