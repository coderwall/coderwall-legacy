module UserCommentsService
  def self.deindex_all_for(user)
    user.comments.each do |comment|
      comment.mark_as_spam
    end
  end
end

