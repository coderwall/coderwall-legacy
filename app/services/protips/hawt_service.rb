module Services
  module Protips
    module FakeHawtService
      def feature!
        Rails.logger.ap("#{self.class.name}#feature!")
      end

      def unfeature!
        Rails.logger.ap("#{self.class.name}#unfeature!")
      end

      def hawt?
        Rails.logger.ap("#{self.class.name}#hawt?")

        false
      end
    end

    module RealHawtService
      def feature!
        url = URI.parse("#{ENV['PRIVATE_URL']}/api/v1/protips/feature.json").to_s
        protip_json = MultiJson.load(protip_hash.to_json)

        Rails.cache.fetch(['hawt_feature', url, protip_hash[:public_id]], expires: 1.hour) do
          RestClient.post(url, protip_json, accept: :json, content_type: 'application/json')
        end
      end

      def unfeature!
        url = URI.parse("#{ENV['PRIVATE_URL']}/api/v1/protips/unfeature.json").to_s
        protip_json = MultiJson.load(protip_hash.to_json)

        Rails.cache.fetch(['hawt_unfeature', url, protip_hash[:public_id]], expires: 1.hour) do
          RestClient.post(url, protip_json, accept: :json, content_type: 'application/json')
        end
      end

      def hawt?
        url = URI.parse("#{ENV['PRIVATE_URL']}/api/v1/protips/hawt.json").to_s
        protip_json = MultiJson.load(protip_hash.to_json)

        Rails.cache.fetch(['hawt_hawt', url, protip_hash[:public_id]], expires: 1.hour) do
          JSON.parse(RestClient.post(url, protip_json, accept: :json, content_type: 'application/json').to_s)['hawt?']
        end
      end
    end

    class HawtService
      if ENV['ENABLE_PRIVATE_API'] || Rails.env.production?
        include RealHawtService
      else
        include FakeHawtService
      end

      def initialize(protip)
        @protip = protip
        @token = SecureRandom.uuid
      end

      def protip_hash
        @protip_hash ||= @protip.as_json(
          methods: [:upvote_velocity, :upvotes, :flagged?, :ever_featured?, :viewed_by_admin?, :networks, :comments, :public_id],
          include: [:user]
        ).merge(token: token, protip_id: protip_id)
      end

      attr_reader :token

      def protip_id
        if @protip.class == Hash
          @protip[:protip_id] || @protip[:id]
        else
          @protip.id
        end
      end
    end
  end
end
