class DeindexUserProtipsService
  def self.run(user)
    user.protips.each do |tip|
      ProtipIndexer.new(tip).remove
    end
  end
end

