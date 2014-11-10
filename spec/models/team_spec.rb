require 'spec_helper'

RSpec.describe Team, :type => :model do
  let(:team) { Fabricate(:team) }
  let(:invitee) { Fabricate(:user) }

  describe '#with_similar_names' do
    let!(:team_1) { Fabricate(:team, name: 'dream_team') }
    let!(:team_2) { Fabricate(:team, name: 'dream_group') }
    let!(:team_3) { Fabricate(:team, name: 'test_team') }

    it 'returns teams with similar names' do
      result = Team.with_similar_names('team')
      expect(result.count).to eq 2
    end

    it 'returns teams using wildcards' do
      result = Team.with_similar_names('dr -.')
      expect(result).to include(team_1, team_2)
    end
  end

  it 'adds the team id to the user when they are added to a team' do
    team.add_user(invitee)
    expect(invitee.reload.team).to eq(team)
  end

  it 'should indicate if team member has referral' do
    member_that_invited_user = Fabricate(:user)
    team.add_user(member_that_invited_user)

    expect(team.has_user_with_referral_token?(member_that_invited_user.referral_token)).to eq(true)
    expect(team.has_user_with_referral_token?("something else")).to eq(false)
  end

  xit 'updates team size when adding and removing member' do
    team_owner = Fabricate(:user)
    @team = Team.find(team.id)
    expect(@team.size).to eq(0)

    @team.add_user(team_owner)
    expect(@team.reload.size).to eq(1)
    @team.remove_user(team_owner)
    expect(@team.reload.size).to eq(0)
  end

  it 'should create a unique slug with no trailing - for each character' do
    team = Team.new(name: 'Tilde Inc .')
    team.valid?
    expect(team.slug).to eq('tilde-inc')
  end

  it 'should clear the cache when a premium team is updated' do
    # TODO: Refactor api calls to Sidekiq job
    VCR.use_cassette('Opportunity') do
      seed_plans!
      Rails.cache.write(Team::FEATURED_TEAMS_CACHE_KEY, 'test')
      team.team_members << admin = Fabricate(:user)
      team.build_account
      team.account.admin_id = admin.id
      team.account.subscribe_to!(Plan.enhanced_team_page_monthly, true)
      expect(Rails.cache.fetch(Team::FEATURED_TEAMS_CACHE_KEY)).to be_nil
    end
  end

  it 'should not clear cache when a normal team is updated' do
    Rails.cache.write(Team::FEATURED_TEAMS_CACHE_KEY, 'test')
    team.name = 'something-else'
    team.save!
    expect(Rails.cache.fetch(Team::FEATURED_TEAMS_CACHE_KEY)).to eq('test')
  end

  it 'should be able to add team link' do
    team.update_attributes(
      featured_links: [{
        name: 'Google',
        url: 'http://www.google.com'
      }])
    expect(team.featured_links.size).to eq(1)
  end

  def seed_plans!(reset=false)
    Plan.destroy_all if reset
    Plan.create(amount: 0, interval: Plan::MONTHLY, name: "Basic") if Plan.enhanced_team_page_free.nil?
    Plan.create(amount: 9900, interval: Plan::MONTHLY, name: "Monthly") if Plan.enhanced_team_page_monthly.nil?
    Plan.create(amount: 19900, interval: nil, name: "Single") if Plan.enhanced_team_page_one_time.nil?
    Plan.create(amount: 19900, interval: Plan::MONTHLY, analytics: true, name: "Analytics") if Plan.enhanced_team_page_analytics.nil?
  end
end
