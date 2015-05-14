class IndexUserProtipsService
  def self.run(user)
    user.protips.each do |tip|
      ProtipIndexer.new(tip).store
    end
  end
end
