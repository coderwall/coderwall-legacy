source 'https://rubygems.org'
source 'https://rails-assets.org'

ruby '2.1.2'

gem 'rails', '~> 3.2'

gem 'sass', '~> 3.2.9'
gem 'coffee-rails', '~> 3.2.1'
gem 'compass-rails'
gem 'sass-rails', '~> 3.2.6'
gem 'uglifier', '>= 1.0.3'
# Assets
gem 'autoprefixer-rails'
gem 'jquery-rails', '= 2.0.3'
gem 'rails-assets-font-awesome'
gem 'rails-assets-jquery-dropdown'

# Two Client-side JS frameworks. Yep, first one to refactor out the other wins.
gem 'backbone-on-rails'
gem 'handlebars-source'
gem 'ember-rails', github: 'emberjs/ember-rails'

# Load environment variables first
gem 'dotenv-rails', groups: [:development, :test]


# Attachements
gem 'carrierwave'
gem 'carrierwave_backgrounder' #background processing of images
gem 'carrierwave-mongoid', require: 'carrierwave/mongoid'

# HTML
gem 'haml'
gem 'hamlbars' #haml support for handlebars/ember.js
gem 'slim-rails'

# Postgres
gem 'pg'

# Scheduled tasks
gem 'clockwork'

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
gem 'redis-rails', '~> 3.2'


gem 'sidekiq'
gem 'sinatra'

# Payment processing
gem 'stripe', github: 'stripe/stripe-ruby'

# RSS parsing
gem 'feedjira'

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
gem 'metamagic'

# ----------------


gem 'acts_as_commentable', '2.0.1'
gem 'acts_as_follower', '0.1.1'
gem 'color'
gem 'createsend'
gem 'fog'
gem 'geocoder'
gem 'hashie'
gem 'linkedin'
gem 'mini_magick'
gem 'mixpanel'
gem 'never_wastes'
gem 'octokit'
gem 'pubnub', '0.1.9'
gem 'querystring'
gem 'rails_autolink'
gem 'rakismet'
gem 'ruby-progressbar'
gem 'sanitize'
gem 'simple_form'
gem 'tweet-button'
gem 'local_time'

# DROP BEFORE RAILS 4
# Mongo
gem 'mongoid'
gem 'mongo'
gem 'mongoid_taggable'
gem 'bson_ext'
#Tagging
gem 'rocket_tag'
gem 'squeel', '1.0.1'
gem 'strong_parameters'
gem 'postgres_ext'
# ElasticSearch client
gem 'tire'
# /DROP BEFORE RAILS 4

group :development do
  gem 'better_errors'
  gem 'flog'
  gem 'fukuzatsu'
  gem 'guard-rspec'
  gem 'rails-erd'
  gem 'rubocop'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'travis'
end

group :development, :test do
  gem 'fabrication-rails'
  gem 'ffaker'
  gem 'jazz_hands', github: 'nixme/jazz_hands', branch: 'bring-your-own-debugger'
  gem 'launchy'
  gem 'pry-byebug'
  gem 'pry-rescue'
  gem 'quiet_assets'
  gem 'syntax'
  gem 'annotate'
  gem 'rspec-rails'
end

group :test do
  # gem 'rspec-its'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'codeclimate-test-reporter', require: false
  gem 'database_cleaner'
  gem 'fuubar', '2.0.0.rc1'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock', '<1.16'
end

group :production do
  gem 'airbrake'
  gem 'newrelic_rpm'
  gem 'puma'
  gem 'rails_12factor'
end
