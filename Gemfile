source 'https://rubygems.org'

ruby '2.1.2'

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
gem 'jbuilder'

# Run app
gem 'foreman'

# Better logging
gem 'awesome_print'

gem 'faraday', '~> 0.8.1'

# ----------------

gem 'rocket_tag', '0.0.4'

gem 'acts_as_commentable', '2.0.1'
gem 'acts_as_follower'
gem 'color'
gem 'createsend'
gem 'fog'
#gem 'font_assets', 'cleanoffer/font_assets'
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
gem 'rakismet'
gem 'ruby-progressbar'
gem 'sanitize'
gem 'simple_form'
gem 'tweet-button'

group :assets do
  gem 'sass', '~> 3.2.9'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'compass-rails'
  gem 'sass-rails', '~> 3.2.6'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'better_errors'
  gem 'flog'
  gem 'fukuzatsu'
  gem 'guard-rspec'
  gem 'rails-erd'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'git_stats', require: false
end

group :development, :test do
  gem 'fabrication-rails'
  gem 'ffaker'
  gem 'jazz_hands', github: 'nixme/jazz_hands', branch: 'bring-your-own-debugger'
  gem 'launchy'
  gem 'letter_opener', github: 'alexrothenberg/letter_opener', branch: 'on_a_server'
  gem 'pry-byebug'
  gem 'quiet_assets'
  gem 'syntax'
end
gem 'mail_view'

group :test do
  gem 'capybara', '~> 1.1'
  gem 'database_cleaner'
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
  gem 'newrelic_resque_agent'
  gem 'newrelic_rpm'
  gem 'puma'
  gem 'puma_worker_killer'
  gem 'rack-attack'
  gem 'rack-cache'
  gem 'rails_12factor'
end
