class SearchSyncJob
  include Sidekiq::Worker

  sidekiq_options queue: :medium

  def perform
    number_of_protips_in_index = Protip.tire.search { query { all } }.total
    number_of_protips_in_database = Protip.count

    if number_of_protips_in_index != number_of_protips_in_database
      protips_in_index = Protip.tire.search do
        size number_of_protips_in_index
        query { all }
      end.map { |protip| protip.id.to_i }

      protips_in_database = Protip.select(:id).map(&:id)

      #now that we know the sets in db and index, calculate the missing records
      nonexistent_protips = (protips_in_index - protips_in_database)
      unindexed_protips = (protips_in_database - protips_in_index)

      nonexistent_protips.each do |nonexistent_protip_id|
        Protip.index.remove({'_id' => nonexistent_protip_id, '_type' => 'protip'})
      end

      unindexed_protips.each do |unindexed_protip_id|
        IndexProtipJob.perform_async(unindexed_protip_id)
      end

      puts "removed #{nonexistent_protips.count} protips and added #{unindexed_protips.count} protips"
    end
  end
end
