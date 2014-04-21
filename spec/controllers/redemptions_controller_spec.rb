require 'spec_helper'

describe RedemptionsController do

  it 'should render page if user not signed in' do
    get :show, code: Redemption::STANDFORD_ACM312.code
    response.should be_success
  end

  describe 'signed in' do
    before :each do
      sign_in(@current_user = Fabricate(:pending_user, last_request_at: 5.minutes.ago))
      get :show, code: Redemption::STANDFORD_ACM312.code
      @current_user.reload
    end

    it 'should activate a new user' do
      @current_user.should be_active
    end

    it 'should redirect the user' do
      response.should redirect_to(user_achievement_url(username: @current_user.username, id: @current_user.badges.first.id))
    end
  end
end
