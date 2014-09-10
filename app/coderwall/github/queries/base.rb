module Coderwall
  module Github
    module Queries
      class Base
        attr_reader :client

        def initialize(client)
          @client = client
        end

        def fetch
          raise NotImplementedError
        end
      end
    end
  end
end
