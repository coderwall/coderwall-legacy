source 'https://rubygems.org'

ruby '2.1.0'

gem 'rails', '~> 3.2'

# Load environment variables first
gem 'dotenv-rails', groups: [:development, :test]

gem 'strong_parameters'

# Mongo
gem 'mongoid', '~> 2.4.12'
gem 'mongo', '<= 1.6.2'
gem 'mongoid_taggable'
gem 'bson_ext', '~> 1.3'

# Attachements
gem 'carrierwave', '0.5.8'
gem 'carrierwave_backgrounder' #background processing of images
gem 'carrierwave-mongoid', '~> 0.1.7', require: 'carrierwave/mongoid'

# Two Client-side JS frameworks. Yep, first one to refactor out the other wins.
gem 'backbone-on-rails'
gem 'ember-rails', github: 'emberjs/ember-rails'
gem 'jquery-rails', '= 2.0.3'

# HTML
gem 'haml', '3.1.7'
gem 'hamlbars' #haml support for handlebars/ember.js

# Memcached
gem 'dalli'
gem 'memcachier'

# Postgres
gem 'pg'

# AREL support for RDBMS queries
gem 'squeel', '1.0.1'

# Authentication
gem 'omniauth', '~> 1.1.0'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-linkedin', '~> 0.0.6'
gem 'omniauth-twitter', '~> 0.0.16'

# Markdown
gem 'redcarpet' #markdown processing
gem 'kramdown'
gem 'github-markdown'

# XML
gem 'nokogiri'

# Hosted on Heroku
gem 'heroku'
gem 'heroku-autoscale', github: 'ndbroadbent/heroku-autoscale'

# Twitter API client
gem 'grackle'
gem 'twitter'

# Paging
gem 'kaminari'

# Date parsing
gem 'chronic'

# Redis
gem 'hiredis'
gem 'redis', require: ['redis', 'redis/connection/hiredis']

# Background Job Processing
gem 'resque'
gem 'resque-scheduler', require: 'resque_scheduler'
gem 'resque_mailer'

# Payment processing
gem 'stripe', github: 'stripe/stripe-ruby'

# RSS parsing
gem 'feedjira'

# ElasticSearch client
gem 'tire', '~> 0.4.1'

# A/B testing
gem 'split', require: 'split/dashboard'

# HTTP client
gem 'rest-client'

# JSON parser
gem 'multi_json'
gem 'oj'
gem 'active_model_serializers'
gem 'jbuilder'

# Run app
gem 'foreman'

# Better logging
gem 'awesome_print'

# Hangup on long calls
gem 'rack-timeout'

gem 'faraday', '~> 0.8.1'

# ----------------

gem 'rocket_tag'

gem 'acts_as_commentable', '2.0.1'
gem 'acts_as_follower'
gem 'color'
gem 'createsend'
gem 'fog'
gem 'font_assets', '~> 0.1.2'
gem 'geocoder'
gem 'hashie'
gem 'linkedin'
gem 'mail'
gem 'mini_magick'
gem 'mixpanel'
gem 'never_wastes'
gem 'octokit', '~> 1.23.0'
gem 'pubnub', '0.1.9'
gem 'querystring'
gem 'rails_autolink'
gem 'ruby-progressbar'
gem 'sanitize'
gem 'simple_form'
gem 'tweet-button'

group :assets do
  gem 'sass', '~> 3.2.9'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'compass-rails'
  gem 'sass-rails', '~> 3.2.3'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'better_errors'
  gem 'guard-rspec'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'rails-erd'
end

group :development, :test do
  gem 'quiet_assets'
  gem 'jazz_hands'
  gem 'launchy'
  gem 'letter_opener', github: 'alexrothenberg/letter_opener', branch: 'on_a_server'
  gem 'syntax'
end
gem 'mail_view'

group :test do
  gem 'capybara', '~> 1.1'
  gem 'database_cleaner'
  gem 'fabrication', '1.4.1'
  gem 'faker'
  gem 'fuubar'
  gem 'resque_spec'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock', '<1.16'
end

group :production do
  gem 'honeybadger'
  gem 'rails_stdout_logging'
  gem 'rails_12factor'
  gem 'unicorn'
  gem 'unicorn-worker-killer'
  gem 'newrelic_rpm'
  gem 'newrelic_resque_agent'
  gem 'le'
end
