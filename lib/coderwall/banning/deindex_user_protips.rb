module Coderwall
  module Banning
    class DeindexUserProtips

      def self.run(user)
        user.protips.each do |tip|
          Coderwall::Search::DeindexProtip.run(tip)
        end
      end

    end
  end
end
