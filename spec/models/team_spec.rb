require 'spec_helper'

describe Team do
  let(:team) { Fabricate(:team) }
  let(:invitee) { Fabricate(:user) }

  it 'adds the team id to the user when they are added to a team' do
    team.add_user(invitee)
    invitee.reload.team.should == team
  end

  it 'should indicate if team member has referral' do
    member_that_invited_user = Fabricate(:user, referral_token: 'asdfasdf')
    team.add_user(member_that_invited_user)

    team.reload_team_members

    team.has_user_with_referral_token?('asdfasdf').should == true
    team.has_user_with_referral_token?("something else").should == false
  end

  it 'updates team size when adding and removing member' do
    team_owner = Fabricate(:user)
    @team = Team.find(team.id)
    @team.size.should == 0

    @team.add_user(team_owner)
    @team.reload.size.should == 1
    @team.remove_user(team_owner)
    @team.reload.size.should == 0
  end

  it 'should create a unique slug with no trailing - for each character' do
    team = Team.new(name: 'Tilde Inc .')
    team.valid?
    team.slug.should == 'tilde-inc'
  end

  it 'should clear the cache when a premium team is updated' do
    seed_plans!
    Rails.cache.write(Team::FEATURED_TEAMS_CACHE_KEY, 'test')
    team.team_members << admin = Fabricate(:user)
    team.build_account
    team.account.admin_id = admin.id
    team.account.subscribe_to!(Plan.enhanced_team_page_monthly, true)
    Rails.cache.fetch(Team::FEATURED_TEAMS_CACHE_KEY).should be_nil
  end

  it 'should not clear cache when a normal team is updated' do
    Rails.cache.write(Team::FEATURED_TEAMS_CACHE_KEY, 'test')
    team.name = 'something-else'
    team.save!
    Rails.cache.fetch(Team::FEATURED_TEAMS_CACHE_KEY).should == 'test'
  end

  it 'should be able to add team link' do
    team.update_attributes(
      featured_links: [{
        name: 'Google',
        url: 'http://www.google.com'
      }])
    team.featured_links.should have(1).link
  end

  def seed_plans!(reset=false)
    Plan.destroy_all if reset
    Plan.create(amount: 0, interval: Plan::MONTHLY, name: "Basic") if Plan.enhanced_team_page_free.nil?
    Plan.create(amount: 9900, interval: Plan::MONTHLY, name: "Monthly") if Plan.enhanced_team_page_monthly.nil?
    Plan.create(amount: 19900, interval: nil, name: "Single") if Plan.enhanced_team_page_one_time.nil?
    Plan.create(amount: 19900, interval: Plan::MONTHLY, analytics: true, name: "Analytics") if Plan.enhanced_team_page_analytics.nil?
  end
end
