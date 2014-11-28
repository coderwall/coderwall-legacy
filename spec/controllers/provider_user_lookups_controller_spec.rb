require 'spec_helper'

RSpec.describe ProviderUserLookupsController, type: :controller, skip: true do
  let(:twitter_username) { 'birdy' }
  let(:github_username) { 'birdy' }
  let(:linked_in_username) { 'birdy' }
  let(:attrs) do
    {
      twitter: twitter_username,
      github: github_username,
      linkedin: linked_in_username
    }
  end
  let!(:user) do
    Fabricate.create(:user, attrs)
  end

  describe 'GET /providers/:provider/:username' do
    describe 'known user' do
      it 'redirects to the current user for twitter' do
        get :show, provider: 'twitter', username: twitter_username
        expect(response).to redirect_to(badge_path(user.username))
      end
    end

    describe 'unknown user' do
      it 'redirects to the current user for twitter' do
        get :show, provider: 'twitter', username: 'unknown'
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eql('User not found')
      end
    end
  end
end
