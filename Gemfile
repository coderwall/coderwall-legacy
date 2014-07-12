source 'https://rubygems.org'

ruby '2.1.2'

gem 'rails', '4.0.6'
gem 'activesupport', '~> 4.0'
gem 'railties', '~> 4.0'
gem 'activerecord-session_store'
gem 'protected_attributes'
gem 'rails-observers'
# Load environment variables first
gem 'dotenv-rails', groups: [:development, :test]

# Mongo
gem 'mongoid', '~> 4.0'
gem 'mongo', '<= 1.6.2'
gem 'mongoid_taggable'
gem 'bson_ext', '~> 1.3'

# Attachements
gem 'carrierwave', '0.10.0'
gem 'carrierwave_backgrounder' #background processing of images
gem 'carrierwave-mongoid', '~> 0.7', require: 'carrierwave/mongoid'

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
gem 'squeel'
# gem 'polyamorous', github: 'activerecord-hackery/polyamorous', branch: 'rails-4.1'

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
gem 'resque-scheduler'
gem 'resque_mailer'

# Payment processing
gem 'stripe', github: 'stripe/stripe-ruby'

# RSS parsing
gem 'feedjira'

# ElasticSearch client
gem 'tire', '~> 0.5'

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

gem 'rocket_tag', github: 'chytreg/rocket_tag', branch: 'feature/rails4-compatibility'

gem 'acts_as_commentable', '2.0.1'
gem 'acts_as_follower'
gem 'color'
gem 'createsend'
gem 'fog'

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

gem 'sass-rails',   '~> 4.0'
gem 'coffee-rails', '~> 4.0.1'
gem 'sass', '~> 3.2.9'
gem 'compass-rails'
gem 'uglifier', '>= 1.3.0'


group :development do
  gem 'better_errors'
  gem 'flog'
  gem 'fukuzatsu'
  gem 'rails-erd'
  gem 'guard-rspec', '4.2.9'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'git_stats', require: false
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'jazz_hands', github: 'nixme/jazz_hands', branch: 'bring-your-own-debugger'
  gem 'launchy'

  # gem 'letter_opener', github: 'alexrothenberg/letter_opener', branch: 'on_a_server'
  gem 'pry-byebug'
  gem 'quiet_assets'

  # gem 'letter_opener', github: 'alexrothenberg/letter_opener', branch: 'on_a_server'
  gem 'syntax'
  gem 'rspec-mocks', '2.14.0'
end
gem 'mail_view'

group :test do
  gem 'capybara', '~> 2.2'
  gem 'database_cleaner'

  gem 'fabrication'

  gem 'fuubar'
  gem 'resque_spec', '~> 0.15'
  gem 'rspec-rails', '~> 2.14'
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
