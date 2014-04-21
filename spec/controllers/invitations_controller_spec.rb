require 'spec_helper'

describe InvitationsController do

  it 'should capture referred by when viewing team invitation' do
    user = Fabricate(:user, referral_token: 'asdfasdf')
    team = Fabricate(:team)
    get :show, id: team.id, r: user.referral_token
    session[:referred_by].should == 'asdfasdf'
  end

end