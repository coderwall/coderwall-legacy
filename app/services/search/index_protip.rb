module Services
  module Search
    class ReindexProtip
      def self.run(protip)
        return if protip.user.banned?

        if Rails.env.development? || Rails.env.test? || protip.destroyed?
          protip.index.store(protip)
        else
          Resque.enqueue(IndexProtip, protip.id)
        end
      end
    end
  end
end
