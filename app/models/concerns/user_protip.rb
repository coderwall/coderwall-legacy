module UserProtip
  extend ActiveSupport::Concern

  def upvoted_protips
    Protip.where(id: Like.where(likable_type: "Protip").where(user_id: self.id).pluck(:likable_id))
  end

  def upvoted_protips_public_ids
    upvoted_protips.pluck(:public_id)
  end

  def bookmarked_protips(count=Protip::PAGESIZE, force=false)
    if force
      self.likes.where(likable_type: 'Protip').map(&:likable)
    else
      Protip.search("bookmark:#{self.username}", [], per_page: count)
    end
  end

  def authored_protips(count=Protip::PAGESIZE, force=false)
    if force
      self.protips
    else
      Protip.search("author:#{self.username}", [], per_page: count)
    end
  end

  def owned_by?(owner)
    user == owner || owner.admin?
  end

  alias_method :owner?, :owned_by?

  private
    def refresh_protips
      protips.each do |protip|
        protip.index_search
      end
      return true
    end
end
