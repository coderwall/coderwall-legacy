class MergeTagJob
  include Sidekiq::Worker

  sidekiq_options queue: :low

  def perform(good_tag_id, bad_tag_id)
    bad_taggings = Tagging.select(:id).where(tag_id: bad_tag_id)
    bad_taggings.find_each(batch_size: 1000) do |bad_tagging|
      enqueue(MergeTaggingJob, good_tag_id, bad_tagging.id)
    end
  end
end