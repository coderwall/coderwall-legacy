module Services
  module Banning
    class DeindexUserProtips
      def self.run(user)
        user.protips.each do |tip|
          Services::Search::DeindexProtip.run(tip)
        end
      end
    end
  end
end
