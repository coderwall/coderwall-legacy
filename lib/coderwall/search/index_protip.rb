module Coderwall
  module Search
    class IndexProtip

      def self.run(protip)
        return if protip.user.banned?
        
        if Rails.env.development? or Rails.env.test? or protip.destroyed?
          protip.index.store(protip)
        else
          Resque.enqueue(::IndexProtip, protip.id)
        end
      end

    end
  end
end
