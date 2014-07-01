module Coderwall
  module Banning
    class IndexUserProtips

      def self.run(user)
        user.protips.each do |tip|
          Coderwall::Search::IndexProtip.run(tip)
        end
      end

    end
  end
end
