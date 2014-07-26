require 'vcr'
require 'rails_helper.rb'

def record_mode
  case ENV['VCR_RECORD_MODE']
	when 'all'
    :all
  when 'new'
    :new_episodes
  else
    :none
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.ignore_localhost                        = true
  c.default_cassette_options                = { record: record_mode }
  c.allow_http_connections_when_no_cassette = false
  c.configure_rspec_metadata!
end

