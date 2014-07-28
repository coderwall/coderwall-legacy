module Services
  module Protips
    class HawtService
      def initialize(protip)
        @protip = protip
      end

      def protip_id
        if @protip.class == Hash
          @protip[:protip_id] || @protip[:id]
        else
          @protip.id
        end
      end

      def feature!
        HawtServiceJob.perform_async(protip_id, 'feature')
      end

      def unfeature!
        HawtServiceJob.perform_async(protip_id, 'unfeature')
      end

      #TODO remove
      def hawt?
        JSON.parse(HawtServiceJob.new.perform(protip_id, 'hawt'))['hawt?']
      end
    end
  end
end
