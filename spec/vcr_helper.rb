require 'vcr'
require 'rails_helper.rb'

VCR.configure do |c|
  c.cassette_library_dir = 'vcr_cassettes'
  c.hook_into :webmock
  c.ignore_localhost                        = true
  c.default_cassette_options                = { record: :new_episodes }
  c.allow_http_connections_when_no_cassette = true
end

RSpec.configure do |c|
  c.around(:each) do |example|
    VCR.use_cassette(example.metadata[:full_description]) do
      example.run
    end
  end
end
