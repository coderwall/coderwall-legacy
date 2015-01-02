source 'https://rubygems.org'
source 'https://rails-assets.org'

ruby '2.1.5'

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
gem 'rails-assets-jquery-cookie',       '1.4.0'
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

# Tagging
gem 'acts-as-taggable-on', '~> 3.4'

gem 'faraday', '~> 0.8.1'
gem 'metamagic'

gem "mail_view", "~> 2.0.4"

# ----------------


gem 'acts_as_commentable', '2.0.1'
gem 'acts_as_follower', '0.1.1'
gem 'color'
gem 'createsend'
gem 'fog'
gem 'friendly_id', '4.0.10.1'
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
gem 'sitemap_generator'
gem 'tweet-button'
gem 'local_time'

gem 'elasticsearch-model'
gem 'elasticsearch-rails'

# DROP BEFORE RAILS 4
# Mongo
gem 'mongoid'
gem 'mongo'
gem 'mongoid_taggable'
gem 'bson_ext'
gem 'strong_parameters'
gem 'postgres_ext'
# ElasticSearch client
gem 'tire'
# /DROP BEFORE RAILS 4

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
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
  gem 'annotate'
  gem 'fabrication-rails'
  gem 'ffaker'
  gem 'jazz_hands', github: 'nixme/jazz_hands', branch: 'bring-your-own-debugger'
  gem 'launchy'
  gem 'pry-byebug'
  #gem 'pry-rescue'
  #gem 'pry-stack_explorer'
  gem 'quiet_assets'
  gem 'rspec-rails'
  gem 'syntax'
end

group :test do
  # gem 'rspec-its'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'turnip' # write rspec feature specs in cucumber style
  gem 'rack_session_access' # allows to set session from within Capybara
  gem 'poltergeist' # headless js driver for Capybara that uses phantomJs
  gem 'selenium-webdriver' # headfull js driver for Capybara
  gem 'codeclimate-test-reporter', require: false
  gem 'database_cleaner'
  gem 'fuubar'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock', '<1.16'
  gem 'stripe-ruby-mock', git: 'https://github.com/rebelidealist/stripe-ruby-mock', branch: 'live-tests'
end

gem 'airbrake'
group :production do
  gem 'newrelic_rpm'
  gem 'puma'
  gem 'rails_12factor'
  gem 'heroku-deflater'
end
