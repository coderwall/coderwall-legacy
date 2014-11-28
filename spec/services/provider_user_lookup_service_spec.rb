require 'spec_helper'

RSpec.describe Services::ProviderUserLookupService do
  let(:twitter_username) { 'birdy' }
  let!(:user) do
    Fabricate.create(:user, twitter: twitter_username)
  end

  describe '#lookup_user' do
    let(:provider) { 'twitter' }
    let(:service) { Services::ProviderUserLookupService.new(provider, username) }

    describe 'unknown provider' do
      let(:provider) { 'unknown' }
      let(:username) { 'unknown' }

      it 'returns nil' do
        expect(service.lookup_user).to be_nil
      end
    end

    describe 'unknown user' do
      let(:username) { 'unknown' }

      it 'returns nil' do
        expect(service.lookup_user).to be_nil
      end
    end

    describe 'known provider and user' do
      let(:username) { twitter_username }

      it 'returns the user' do
        expect(service.lookup_user).to eql(user)
      end
    end
  end
end
