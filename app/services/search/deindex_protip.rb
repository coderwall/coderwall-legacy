module Services
  module Search
    class DeindexProtip
      def self.run(protip)
        protip.index.remove(protip)
      end
    end
  end
end
