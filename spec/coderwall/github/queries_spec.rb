require 'vcr_helper'

describe Coderwall::Github::Queries do

  let(:user) { Fabricate(:user) }
  let(:client) { Coderwall::Github::Client.new(user.github_token).client }

  describe 'ProfileFor' do
    subject { Coderwall::Github::Queries::ProfileFor.new(client, github_username) }

    let(:github_username) { 'just3ws' }

    it 'sets the client reader' do
      expect(subject.client).to_not be_nil
    end

    it 'inherits from Queries::Base' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Base)
    end

    it 'filters the user attribute' do
      user = VCR.use_cassette('fetch github user for just3ws') do
        subject.fetch
      end

      Coderwall::Github::Queries::ProfileFor.exclude_attributes do |exclude_attribute|
        expect(user.has_key?(exclude_attribute)).to be false
      end
    end
  end
end
