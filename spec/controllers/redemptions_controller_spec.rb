require 'spec_helper'

RSpec.describe RedemptionsController, type: :controller, skip: true do

  it 'should render page if user not signed in' do
    get :show, code: Redemption::STANDFORD_ACM312.code
    expect(response).to be_success
  end

  describe 'signed in' do
    before :each do
      sign_in(@current_user = Fabricate(:pending_user, last_request_at: 5.minutes.ago))
      get :show, code: Redemption::STANDFORD_ACM312.code
      @current_user.reload
    end

    it 'should activate a new user' do
      expect(@current_user).to be_active
    end

    it 'should redirect the user' do
      expect(response).to redirect_to(user_achievement_url(username: @current_user.username, id: @current_user.badges.first.id))
    end
  end
end
