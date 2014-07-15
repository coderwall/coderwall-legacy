class MergeTagging < Struct.new(:good_tag_id, :bad_tagging_id)
  extend ResqueSupport::Basic

  @queue = 'LOW'

  def perform
    bad_tagging = Tagging.find(bad_tagging_id)
    good_tagging = Tagging.where(taggable_type: bad_tagging.taggable_type, taggable_id: bad_tagging.taggable_id,
                                 context: bad_tagging.context, tagger_id: bad_tagging.tagger_id, tagger_type: bad_tagging.tagger_type).first

    if good_tagging.nil?
      bad_tagging.tag_id = good_tag_id
      bad_tagging.save
    else
      bad_tagging.destroy
    end
  end
end
