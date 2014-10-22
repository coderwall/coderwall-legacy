module Coderwall
  module GitHub
    ACCESS_TOKEN ||= ENV['GITHUB_ACCESS_TOKEN']
    CLIENT_ID ||= ENV['GITHUB_CLIENT_ID']
    SECRET    ||= ENV['GITHUB_SECRET']
  end
end
