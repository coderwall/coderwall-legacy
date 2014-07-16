module Services
  module Banning
    class IndexUserProtips
      def self.run(user)
        user.protips.each do |tip|
          ProtipIndexer.new(tip).store
        end
      end
    end
  end
end
