require 'vcr_helper'

VCR.configure do |c|
  c.default_cassette_options = {
    match_requests_on:
      [ :method,
        VCR.request_matchers.uri_without_param(:client_id, :client_secret)]
  }
end

RSpec.describe Ashcat, type: :model do
  let(:contributor) { Fabricate(:user, github: 'dhh') }

  it 'creates facts for each contributor' do
    # TODO: Refactor to utilize sidekiq job
    VCR.use_cassette('Ashcat') do
      Ashcat.perform

      badge = Ashcat.new(contributor)
      expect(badge.award?).to eq(true)
      expect(badge.reasons).to match(/Contributed \d+ times to Rails Core/)
    end
  end
end
