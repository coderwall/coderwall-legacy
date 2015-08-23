module UserProtipsService
  def self.deindex_all_for(user)
    user.protips.each do |protip|
      protip.mark_as_spam
      ProtipIndexer.new(protip).remove
    end
  end

  def self.reindex_all_for(user)
    user.protips.each do |protip|
      ProtipIndexer.new(protip).store
    end
  end
end

