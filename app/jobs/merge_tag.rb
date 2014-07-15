class MergeTag < Struct.new(:good_tag_id, :bad_tag_id)
  extend ResqueSupport::Basic

  @queue = 'LOW'

  def perform
    bad_taggings = Tagging.select(:id).where(tag_id: bad_tag_id)
    bad_taggings.find_each(batch_size: 1000) do |bad_tagging|
      enqueue(MergeTagging, good_tag_id, bad_tagging.id)
    end
  end
end
