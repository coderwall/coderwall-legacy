class ProcessProtipJob
  include Sidekiq::Worker

  sidekiq_options queue: :protip

  def perform(process_type, protip_id)
    begin
      protip = Protip.find(protip_id)
      case process_type
        when 'recalculate_score'
          protip.update_score!(true)
        when 'resave'
          protip.save
        when 'delete'
          protip.destroy
        when 'cache_score'
          protip.upvotes_value = protip.upvotes_value(true)
          protip.save(validate: false)
      end
    rescue ActiveRecord::RecordNotFound
      return
    end
  end
end
