require "rails_helper"

feature "Teams management", js: true do

  background do
    stub_request(:post, /api.mixpanel.com/)
    login_as(username: 'alice', bypass_ui_login: true)
  end

  context 'creating a team with no similar names in db' do
    scenario 'create a new team' do
      create_team('TEST_TEAM')
      expect(page).to have_content('Successfully created a team TEST_TEAM')
    end

    scenario 'add user to the newly created team' do
      create_team('TEST_TEAM')

      find('section.feature.payment') # ensures that we wait until the create_team action completes
      visit '/alice'

      expect(page).to have_content('TEST_TEAM')
    end

    scenario 'show payment plans selection' do
      create_team('TEST_TEAM')

      expect(page).to have_content('Select a plan and enter payment details to get started')
      expect(page).to have_content('FREE')
      expect(page).to have_content('MONTHLY')
      expect(page).to have_content('ANALYTICS')
    end

    scenario 'redirect to team profile page when user selects FREE plan' do
      create_team('TEST_TEAM')
      find('section.feature.payment').find('.plans .plan.free').click_link 'Select plan'

      team_id = Team.any_of({name: 'TEST_TEAM'}).first.id
      expect(current_path).to eq(team_path(team_id))
    end
  end

  context 'create a team with similar names already in db' do
    let!(:team) { Team.create(name: 'EXISTING_TEAM') }

    scenario 'create a new team' do
      create_team('TEAM')

      expect(page).to have_content('We found some matching teams')
      expect(page).to have_content('EXISTING_TEAM')
      expect(page).to have_content('Select')
      expect(page).to have_content('None of the above are my team')
      expect(page).to have_content('Create team TEAM')
    end

    scenario 'create a new team with originally supplied name' do
      create_team('TEAM')
      find('.just-create-team').click_link('Create team TEAM')
      expect(page).to have_content('Successfully created a team TEAM')
    end

    scenario 'attempt to create a team with exact name already in db' do
      create_team('EXISTING_TEAM')
      find('.just-create-team').click_link('Create team EXISTING_TEAM')
      expect(page).to have_content('There was an error in creating a team EXISTING_TEAM')
      expect(page).to have_content('Name is already taken')
    end
  end

  context 'join a team with a similar name' do
    let!(:team) { Team.create(name: 'EXISTING_TEAM') }

    scenario 'join an existing team' do
      create_team('TEAM')

      find('.results-list').click_link('Select')

      expect(page).to have_content('Select a plan and enter payment details to get started')
      expect(page).to have_content('I work at EXISTING_TEAM and just want to join the team')
      expect(page).to have_content('Request to join team')
    end

    scenario 'request to join a team' do
      create_team('TEAM')

      find('.results-list').click_link('Select')
      find('section.feature.payment').click_link 'Request to join team'

      expect(current_path).to eq(teamname_path(team.slug))
      expect(page).to have_content('We have submitted your join request to the team admin to approve')
    end
  end


end
