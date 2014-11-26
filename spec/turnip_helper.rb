require 'rails_helper.rb'
require 'turnip/capybara'

Dir.glob('spec/features/steps/**/*steps.rb') { |file| load file, true }
