module Coderwall
  module GitHub
    module Queries
      class Base
        attr_reader :client

        def initialize(client)
          @client = client
        end

        def fetch
          raise NotImplementedError
        end

        def friendly_thing_name
          self.class.name.underscore.split('/').last.gsub('_', ' ')
        end
      end
    end
  end
end
