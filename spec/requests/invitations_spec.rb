require 'spec_helper'

RSpec.describe "Viewing an invitation", :type => :request do

  before :each do
    @user = Fabricate(:user)
    @team = Fabricate(:team)
  end

  describe 'when logged in' do

    def sign_in
      allow(User).to receive(:find_with_oauth).and_return(@user)
      post "/sessions"
    end

    it "should render invitation page for logged in user" do
      sign_in

      # Stub out what we need from our controller
      allow(Team).to receive(:find).with(@team.id).and_return(@team)
      allow(@team).to receive(:has_user_with_referral_token?).and_return(true)
      allow(@team).to receive(:top_three_team_members).and_return([@user])

      get invitation_url(id: @team.id,r: @user.referral_token)

      expect(response.body).to include("Join this team")
      expect(response).to render_template("invitations/show")
      expect(response.code).to eq("200")
    end

  end

  describe "when logged out" do
    it "should show invitation page asking user to sign in" do
      # Stub out what we need from our controller
      allow(Team).to receive(:find).with(@team.id).and_return(@team)
      allow(@team).to receive(:has_user_with_referral_token?).and_return(true)

      get invitation_url(id: @team.id,r: @user.referral_token)

      expect(response.body).to include("you need to create a coderwall account")
      expect(response).to render_template("invitations/show")
      expect(response.code).to eq("200")
    end
      
  end

end
