require 'spec_helper'

RSpec.describe TeamsController, :type => :controller do
  let(:current_user) { Fabricate(:user) }
  let(:team) { Fabricate(:team) }

  before { controller.send :sign_in, current_user }

  it 'allows user to follow team' do
    post :follow, id: team.id
    expect(current_user.following_team?(team)).to eq(true)
  end

  it 'allows user to stop follow team' do
    current_user.follow_team!(team)
    post :follow, id: team.id
    current_user.reload
    expect(current_user.following_team?(team)).to eq(false)
  end

end