module Coderwall
  module GitHub
    class Client
      attr_reader :client
      attr_reader :access_token

      def initialize(git_hub_access_token)
        fail(MissingAccessTokenError, 'GitHub access token in required.') if git_hub_access_token.nil?
        fail(InvalidAccessTokenError, 'Valid GitHub access token in required.') if !git_hub_access_token.is_a?(String) || git_hub_access_token.blank?

        @access_token = git_hub_access_token
        @client = Octokit::Client.new(access_token: @access_token, auto_paginate: true)
      end

      def self.instance(access_token = nil)
        if access_token.blank?
          Rails.logger.warn("Blank access_token passed to Coderwall::GitHub::Client.instance so falling back to use Coderwall's access_token.")
          access_token = Coderwall::GitHub::ACCESS_TOKEN
        end
        Coderwall::GitHub::Client.new(access_token).client
      end
    end

    class MissingAccessTokenError < StandardError
    end

    class InvalidAccessTokenError < StandardError
    end
  end
end
