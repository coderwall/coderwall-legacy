# encoding: utf-8

module AuthHelper
  def http_authorize!(username = ENV['HTTP_AUTH_USERNAME'], password = ENV['HTTP_AUTH_PASSWORD'])
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end
end
