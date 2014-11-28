require 'spec_helper.rb'

require 'capybara/poltergeist'
require 'capybara-screenshot/rspec'
require 'rack_session_access/capybara'
require 'features/helpers/general_helpers.rb'

Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = 5

RSpec.configure do |config|
  config.before(:example, js: :true) do
    DatabaseCleaner.strategy = :truncation
    ActiveRecord::Base.establish_connection
  end

  config.include Features::GeneralHelpers, type: :feature
end
