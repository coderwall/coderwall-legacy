ruby '2.2.2'

source 'https://rubygems.org' do
  gem 'rails', '~> 3.2'
  gem 'rails_latest'

  gem 'sass'
  gem 'coffee-rails'
  gem 'sass-rails'
  gem 'uglifier'
# Assets
  gem 'autoprefixer-rails'
  gem 'jquery-rails', '= 2.0.3'
  gem 'selectize-rails'

# Load environment variables first
  gem 'dotenv-rails', groups: [:development, :test]

# Attachements
  gem 'carrierwave'
  gem 'carrierwave_backgrounder' #background processing of images

# HTML
  gem 'haml'
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
  gem 'redcarpet', ">=3.3.4"
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
  gem 'redis-rails', '3.2.4'


  gem 'sidekiq'
  gem 'sinatra'

# Payment processing
  gem 'stripe'

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


# ----------------

  gem 'acts_as_follower', '0.1.1'
  gem 'fog'
  gem 'friendly_id', '4.0.10.1'
  gem 'geocoder'
  gem 'linkedin'
  gem 'mini_magick'
  gem 'mixpanel'
  gem 'never_wastes'
  gem 'octokit'
  gem 'rakismet'
  gem 'sanitize'
  gem 'simple_form'
  gem 'sitemap_generator'
  gem 'tweet-button'
  gem 'local_time'
  gem 'materialize-sass'

  gem 'closure_tree'

  gem 'elasticsearch-model'
  gem 'elasticsearch-rails'

  gem 'newrelic_rpm'

# DROP BEFORE RAILS 4
  gem 'compass-rails'
  gem 'strong_parameters'
  gem 'postgres_ext'
  gem 'test-unit'
  gem 'foreigner'
  gem 'state_machine'
  gem 'activerecord-postgres-json'
  gem "mail_view", "~> 2.0.4"

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
    gem 'pry-rails' #better console
  end

  group :development, :test do
    gem 'annotate'
    gem 'fabrication', '2.11.3'
    gem 'fabrication-rails'
    gem 'ffaker'
    gem 'launchy'
    gem 'pry-byebug'
    #gem 'pry-rescue'
    #gem 'pry-stack_explorer'
    gem 'quiet_assets'
    gem 'rspec-rails'
    gem 'syntax'
  end

  group :test do
    gem 'capybara'
    gem 'capybara-screenshot'
    gem 'rack_session_access' # allows to set session from within Capybara
    gem 'poltergeist' # headless js driver for Capybara that uses phantomJs
    gem 'selenium-webdriver' # headfull js driver for Capybara
    gem 'codeclimate-test-reporter', require: false
    gem 'database_cleaner'
    gem 'fuubar'
    gem 'shoulda-matchers'
    gem 'timecop'
    gem 'vcr'
    gem 'webmock', '<1.16'
    gem 'stripe-ruby-mock'
  end

  group :production do
    gem 'puma', '>=2.15.3'
    gem 'rails_12factor'
    gem 'heroku-deflater'
    gem 'bugsnag'
  end
end

source 'https://rails-assets.org' do
  gem 'rails-assets-font-awesome'
  gem 'rails-assets-jquery-cookie', '1.4.0'
  gem 'rails-assets-jquery-dropdown'
end
