require File.expand_path('../config/application', __FILE__)
require 'rake'
require 'rspec/core/rake_task'

Coderwall::Application.load_tasks

RSpec::Core::RakeTask.new(:spec) do
  `rake db:test:prepare`
  Rake::Task['db']['test']['prepare'].execute
end

task default: :spec

puts "RAILS_ENV=#{Rails.env}"
