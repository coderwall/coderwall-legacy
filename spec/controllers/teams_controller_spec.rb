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

  describe "#create" , focus: true  do
    let(:team) { Fabricate.build(:team) }

    it 'renders an error message if action was unsuccessful' do

    end

    context 'a team is selected from a list of similar teams' do
      it 'renders a template with a choice of tariff plans when user selects a team' do
        post :create, :team => { selected: 'true', slug: 'team_name' }, format: :js
        expect(response).to render_template('create')
      end
    end

    context 'a team does not exist' do
      let(:response) { post :create, :team => { name: 'team_name' }, format: :js }

      before do
        allow(controller).to receive(:get_similar_teams).and_return(nil)

        allow(Team).to receive(:new).and_return(team)
        allow(team).to receive(:save).and_return(true)
        allow(team).to receive(:add_user).and_return(true)
      end

      it 'creates a new team' do
        expect(team).to receive(:save)
        response
      end

      it 'adds current user to the team' do
        expect(team).to receive(:add_user).with(current_user)
        response
      end

      it 'records an event "created team"' do
        expect(controller).to receive(:record_event).with('created team')
        response
      end

      it 'renders template with option to join' do
        expect(response).to be_success
        expect(response).to render_template('create')
      end
    end

    context 'a team with similar name already exists' do
      before do
        allow(Team).to receive(:new).and_return(team)
        allow(Team).to receive(:with_similar_names).and_return([ team ])
      end

      it 'renders a template with a list of similar teams' do
        post :create, :team => { name: 'team_name' }, format: :js
        expect(response).to render_template('similar_teams')
      end
    end
  end

end
