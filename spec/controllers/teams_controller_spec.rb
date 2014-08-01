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

  describe 'GET #index' do
    it 'responds successfully with an HTTP 200 status code' do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end


  describe 'GET #show' do
    it 'responds successfully with an HTTP 200 status code' do
      team = Fabricate(:team) do
        name Faker::Company.name
        slug Faker::Internet.user_name
      end
      get :show, slug: team.slug
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

end