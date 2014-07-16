require 'spec_helper'

RSpec.describe InvitationsController, :type => :controller do

  it 'should capture referred by when viewing team invitation' do
    user = Fabricate(:user, referral_token: 'asdfasdf')
    team = Fabricate(:team)
    get :show, id: team.id, r: user.referral_token
    expect(session[:referred_by]).to eq('asdfasdf')
  end

end