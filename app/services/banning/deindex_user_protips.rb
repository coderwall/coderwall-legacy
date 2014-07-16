module Services
  module Banning
    class DeindexUserProtips
      def self.run(user)
        user.protips.each do |tip|
          ProtipIndexer.new(tip).remove
        end
      end
    end
  end
end
