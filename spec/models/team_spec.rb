require 'rails_helper'

RSpec.describe Team, :type => :model do
  it { is_expected.to have_one :account }

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

  it { is_expected.to have_many :locations }
  it { is_expected.to have_many :links }
  it { is_expected.to have_many :members }
  it { is_expected.to have_many :jobs }
  it { is_expected.to have_many :followers }

end

# == Schema Information
# Schema version: 20140918031936
#
# Table name: teams
#
#  id                       :integer          not null, primary key
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  website                  :string(255)
#  about                    :text
#  total                    :float            default(0.0)
#  size                     :integer          default(0)
#  mean                     :float            default(0.0)
#  median                   :float            default(0.0)
#  score                    :float            default(0.0)
#  twitter                  :string(255)
#  facebook                 :string(255)
#  slug                     :string(255)
#  premium                  :boolean          default(FALSE)
#  analytics                :boolean          default(FALSE)
#  valid_jobs               :boolean          default(FALSE)
#  hide_from_featured       :boolean          default(FALSE)
#  preview_code             :string(255)
#  youtube_url              :string(255)
#  github                   :string(255)
#  highlight_tags           :string(255)
#  branding                 :text
#  headline                 :text
#  big_quote                :text
#  big_image                :string(255)
#  featured_banner_image    :string(255)
#  benefit_name_1           :text
#  benefit_description_1    :text
#  benefit_name_2           :text
#  benefit_description_2    :text
#  benefit_name_3           :text
#  benefit_description_3    :text
#  reason_name_1            :text
#  reason_description_1     :text
#  reason_name_2            :text
#  reason_description_2     :text
#  reason_name_3            :text
#  reason_description_3     :text
#  why_work_image           :text
#  organization_way         :text
#  organization_way_name    :text
#  organization_way_photo   :text
#  featured_links_title     :string(255)
#  blog_feed                :text
#  our_challenge            :text
#  your_impact              :text
#  hiring_tagline           :text
#  link_to_careers_page     :text
#  avatar                   :string(255)
#  achievement_count        :integer          default(0)
#  endorsement_count        :integer          default(0)
#  upgraded_at              :datetime
#  paid_job_posts           :integer          default(0)
#  monthly_subscription     :boolean          default(FALSE)
#  stack_list               :text             default("")
#  number_of_jobs_to_show   :integer          default(2)
#  location                 :string(255)
#  country_id               :integer
#  name                     :string(255)
#  github_organization_name :string(255)
#  team_size                :integer
#  mongo_id                 :string(255)
#  office_photos            :string(255)      default([]), is an Array
#  upcoming_events          :text             default([]), is an Array
#  interview_steps          :text             default([]), is an Array
#  invited_emails           :string(255)      default([]), is an Array
#  pending_join_requests    :string(255)      default([]), is an Array
#  state                    :string(255)      default("active")
#
