module Coderwall
  module Github
    class Client
      attr_reader :client
      attr_reader :access_token

      def initialize(github_access_token)
        fail(MissingAccessTokenError, 'Github access token in required.') if github_access_token.nil?
        fail(InvalidAccessTokenError, 'Valid Github access token in required.') if !github_access_token.is_a?(String) || github_access_token.blank?

        @access_token = github_access_token
        @client = Octokit::Client.new(access_token: @access_token, auto_paginate: true)
      end
    end

    class MissingAccessTokenError < StandardError
    end

    class InvalidAccessTokenError < StandardError
    end
  end
end
