class MergeDuplicateLink < Struct.new(:link)
  extend ResqueSupport::Basic

  @queue = 'LOW'

  def perform
    all_links = ProtipLink.where(url: link).order('created_at ASC')
    protip_to_keep = all_links.shift.protip
    # merge
    all_links.each do |duplicate_link|
      if duplicate_link.protip.created_automagically?
        duplicate_link.protip.likes.each do |like|
          like.likable_id = protip_to_keep.id
        end
        duplicate_link.protip.destroy
      end
    end
  end
end
