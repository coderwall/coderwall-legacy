# Use the old API syntax
Octokit.default_media_type = 'application/vnd.github.beta+json'
Octokit.auto_paginate = true

stack = Faraday::Builder.new do |builder|
  if ENV['OCTOKIT_LOG']
    builder.response(:logger)
  end

  if ENV['OCTOKIT_DEBUG']
    builder.use Octokit::Response::RaiseError
  end

  if ENV['OCTOKIT_CACHE']
    builder.use :http_cache, store: Rails.cache
  end

  builder.adapter Faraday.default_adapter
end
Octokit.middleware = stack
