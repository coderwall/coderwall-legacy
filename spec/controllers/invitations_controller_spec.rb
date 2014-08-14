require 'spec_helper'

RSpec.describe InvitationsController, :type => :controller do

  it 'should capture referred by when viewing team invitation' do
    user = Fabricate(:user, referral_token: 'asdfasdf')
    team = Fabricate(:team)
    get :show, id: team.id, r: user.referral_token
    expect(session[:referred_by]).to eq('asdfasdf')
  end

  describe "GET invitations#show" do
    
    let(:current_user)  { Fabricate(:user) }
    let(:team)          { Fabricate(:team) }
      
    describe "logged in" do
      before { controller.send :sign_in, current_user }

      it "should render invitation page successfully with valid referral" do
        allow(Team).to receive(:find).with(team.id).and_return(team)
        allow(team).to receive(:has_user_with_referral_token?).and_return(true)

        get :show, id: team.id
        expect(assigns(:team)).to eq(team)
        expect(response).to render_template("invitations/show")
      end

      it "should redirect to root_url with invalid referral" do
        allow(Team).to receive(:find).with(team.id).and_return(team)
        allow(team).to receive(:has_user_with_referral_token?).and_return(false)

        get :show, id: team.id
        expect(response).to redirect_to(root_url)
      end


    end

    describe "logged out" do
      it "should render invitation page successfully with valid referral" do
        allow(Team).to receive(:find).with(team.id).and_return(team)
        allow(team).to receive(:has_user_with_referral_token?).and_return(true)

        get :show, id: team.id
        expect(assigns(:team)).to eq(team)
        expect(response).to render_template("invitations/show")
      end

      it "should redirect to root_url with invalid referral" do
        allow(Team).to receive(:find).with(team.id).and_return(team)
        allow(team).to receive(:has_user_with_referral_token?).and_return(false)

        get :show, id: team.id
        expect(response).to redirect_to(root_url)
      end
    end
    
  end

  

end
