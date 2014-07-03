module Services
  module Banning
    class IndexUserProtips
      def self.run(user)
        user.protips.each do |tip|
          Services::Search::IndexProtip.run(tip)
        end
      end
    end
  end
end
