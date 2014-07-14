# == Schema Information
#
# Table name: users
#
#  id                            :integer          not null, primary key
#  username                      :string(255)
#  name                          :string(255)
#  email                         :string(255)
#  location                      :string(255)
#  old_github_token              :string(255)
#  state                         :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  twitter                       :string(255)
#  linkedin_legacy               :string(255)
#  stackoverflow                 :string(255)
#  admin                         :boolean          default(FALSE)
#  backup_email                  :string(255)
#  badges_count                  :integer          default(0)
#  bitbucket                     :string(255)
#  codeplex                      :string(255)
#  login_count                   :integer          default(0)
#  last_request_at               :datetime
#  achievements_checked_at       :datetime         default(1914-02-20 22:39:10 UTC)
#  claim_code                    :text
#  github_id                     :integer
#  country                       :string(255)
#  city                          :string(255)
#  state_name                    :string(255)
#  lat                           :float
#  lng                           :float
#  http_counter                  :integer
#  github_token                  :string(255)
#  twitter_checked_at            :datetime         default(1914-02-20 22:39:10 UTC)
#  title                         :string(255)
#  company                       :string(255)
#  blog                          :string(255)
#  github                        :string(255)
#  forrst                        :string(255)
#  dribbble                      :string(255)
#  specialties                   :text
#  notify_on_award               :boolean          default(TRUE)
#  receive_newsletter            :boolean          default(TRUE)
#  zerply                        :string(255)
#  thumbnail_url                 :text
#  linkedin                      :string(255)
#  linkedin_id                   :string(255)
#  linkedin_token                :string(255)
#  twitter_id                    :string(255)
#  twitter_token                 :string(255)
#  twitter_secret                :string(255)
#  linkedin_secret               :string(255)
#  last_email_sent               :datetime
#  linkedin_public_url           :string(255)
#  beta_access                   :boolean          default(FALSE)
#  redemptions                   :text
#  endorsements_count            :integer          default(0)
#  team_document_id              :string(255)
#  speakerdeck                   :string(255)
#  slideshare                    :string(255)
#  last_refresh_at               :datetime         default(1970-01-01 00:00:00 UTC)
#  referral_token                :string(255)
#  referred_by                   :string(255)
#  about                         :text
#  joined_github_on              :date
#  joined_twitter_on             :date
#  avatar                        :string(255)
#  banner                        :string(255)
#  remind_to_invite_team_members :datetime
#  activated_on                  :datetime
#  tracking_code                 :string(255)
#  utm_campaign                  :string(255)
#  score_cache                   :float            default(0.0)
#  notify_on_follow              :boolean          default(TRUE)
#  api_key                       :string(255)
#  remind_to_create_team         :datetime
#  remind_to_create_protip       :datetime
#  remind_to_create_skills       :datetime
#  remind_to_link_accounts       :datetime
#  favorite_websites             :string(255)
#  team_responsibilities         :text
#  team_avatar                   :string(255)
#  team_banner                   :string(255)
#  ip_lat                        :float
#  ip_lng                        :float
#  penalty                       :float            default(0.0)
#  receive_weekly_digest         :boolean          default(TRUE)
#  github_failures               :integer          default(0)
#  resume                        :string(255)
#  sourceforge                   :string(255)
#  google_code                   :string(255)
#  visits                        :string(255)      default("")
#  visit_frequency               :string(255)      default("rarely")
#  join_badge_orgs               :boolean          default(FALSE)
#  last_asm_email_at             :datetime
#  banned_at                     :datetime
#  last_ip                       :string(255)
#  last_ua                       :string(255)
#
# Indexes
#
#  index_users_on_github_token      (old_github_token) UNIQUE
#  index_users_on_linkedin_id       (linkedin_id) UNIQUE
#  index_users_on_team_document_id  (team_document_id)
#  index_users_on_twitter_id        (twitter_id) UNIQUE
#  index_users_on_username          (username) UNIQUE
#

require 'spec_helper'

RSpec.describe User, :type => :model do
  before :each do
    User.destroy_all
  end

  describe 'viewing' do
    it 'tracks when a user views a profile' do
      user = Fabricate :user
      viewer = Fabricate :user
      user.viewed_by(viewer)
      expect(user.viewers.first).to eq(viewer)
      expect(user.total_views).to eq(1)
    end

    it 'tracks when a user views a profile' do
      user = Fabricate :user
      user.viewed_by(nil)
      expect(user.total_views).to eq(1)
    end
  end

  it 'should create a token on creation' do
    user = Fabricate(:user)
    expect(user.referral_token).not_to be_nil
  end

  it 'should not allow the username in multiple cases to be use on creation' do
    user = Fabricate(:user, username: 'MDEITERS')
    lambda {
      expect(Fabricate(:user, username: 'mdeiters')).to raise_error('Validation failed: Username has already been taken')
    }
  end

  it 'should not return incorrect user because of pattern matching' do
    user = Fabricate(:user, username: 'MDEITERS')
    found = User.with_username('M_EITERS')
    expect(found).not_to eq(user)
  end

  it 'should find users by username when provider is blank' do
    user = Fabricate(:user, username: 'mdeiters')
    expect(User.with_username('mdeiters', '')).to eq(user)
    expect(User.with_username('mdeiters', nil)).to eq(user)
  end

  it 'should find users ignoring case' do
    user = Fabricate(:user, username: 'MDEITERS', twitter: 'MDEITERS', github: 'MDEITERS', linkedin: 'MDEITERS')
    expect(User.with_username('mdeiters')).to eq(user)
    expect(User.with_username('mdeiters', :twitter)).to eq(user)
    expect(User.with_username('mdeiters', :github)).to eq(user)
    expect(User.with_username('mdeiters', :linkedin)).to eq(user)
  end

  it 'should return users with most badges' do
    user_with_2_badges = Fabricate :user, username: 'somethingelse'
    badge1 = user_with_2_badges.badges.create!(badge_class_name: Mongoose3.name)
    badge2 = user_with_2_badges.badges.create!(badge_class_name: Octopussy.name)

    user_with_3_badges = Fabricate :user
    badge1 = user_with_3_badges.badges.create!(badge_class_name: Mongoose3.name)
    badge2 = user_with_3_badges.badges.create!(badge_class_name: Octopussy.name)
    badge3 = user_with_3_badges.badges.create!(badge_class_name: Mongoose.name)

    expect(User.top(1)).to include(user_with_3_badges)
    expect(User.top(1)).not_to include(user_with_2_badges)
  end

  it 'should require valid email when instantiating' do
    u = Fabricate.build(:user, email: 'someting @ not valid.com', state: nil)
    expect(u.save).to be_falsey
    expect(u).not_to be_valid
    expect(u.errors[:email]).not_to be_empty
  end

  it 'returns badges in order created with latest first' do
    user = Fabricate :user
    badge1 = user.badges.create!(badge_class_name: Mongoose3.name)
    badge2 = user.badges.create!(badge_class_name: Octopussy.name)
    badge3 = user.badges.create!(badge_class_name: Mongoose.name)

    expect(user.badges.first).to eq(badge3)
    expect(user.badges.last).to eq(badge1)
  end

  class NotaBadge < BadgeBase
  end

  class AlsoNotaBadge < BadgeBase
  end

  it 'should award user with badge' do
    user = Fabricate :user
    user.award(NotaBadge.new(user))
    expect(user.badges.size).to eq(1)
    expect(user.badges.first.badge_class_name).to eq(NotaBadge.name)
  end

  it 'instantiates new user with omniauth if the user is not on file' do
    omniauth = {"info" => {"name" => "Matthew Deiters", "urls" => {"Blog" => "http://www.theagiledeveloper.com", "GitHub" => "http://github.com/mdeiters"}, "nickname" => "mdeiters", "email" => ""}, "uid" => 7330, "credentials" => {"token" => "f0f6946eb12c4156a7a567fd73aebe4d3cdde4c8"}, "extra" => {"user_hash" => {"plan" => {"name" => "micro", "collaborators" => 1, "space" => 614400, "private_repos" => 5}, "gravatar_id" => "aacb7c97f7452b3ff11f67151469e3b0", "company" => nil, "name" => "Matthew Deiters", "created_at" => "2008/04/14 15:53:10 -0700", "location" => "", "disk_usage" => 288049, "collaborators" => 0, "public_repo_count" => 18, "public_gist_count" => 31, "blog" => "http://www.theagiledeveloper.com", "following_count" => 27, "id" => 7330, "owned_private_repo_count" => 2, "private_gist_count" => 2, "type" => "User", "permission" => nil, "total_private_repo_count" => 2, "followers_count" => 19, "login" => "mdeiters", "email" => ""}}, "provider" => "github"}

    user = User.for_omniauth(omniauth.with_indifferent_access)
    expect(user).to be_new_record
  end

  it 'increments the badge count when you add new badges' do
    user = Fabricate :user

    user.award(NotaBadge.new(user))
    user.save!
    user.reload
    expect(user.badges_count).to eq(1)

    user.award(AlsoNotaBadge.new(user))
    user.save!
    user.reload
    expect(user.badges_count).to eq(2)
  end

  it 'should randomly select the user with badges' do
    user = Fabricate :user
    user.award(NotaBadge.new(user))
    user.award(NotaBadge.new(user))
    user.save!

    user2 = Fabricate :user, username: 'different', github_token: 'unique'

    4.times do
      expect(User.random).not_to eq(user2)
    end
  end

  it 'should not allow adding the same badge twice' do
    user = Fabricate :user
    user.award(NotaBadge.new(user))
    user.award(NotaBadge.new(user))
    user.save!
    expect(user.badges.count).to eq(1)
  end

  describe "redemptions" do
    it "should have an empty list of redemptions when new" do
      expect(Fabricate.build(:user).redemptions).to be_empty
    end

    it "should have a single redemption with a redemptions list of one item" do
      user = Fabricate.build(:user, redemptions: %w{railscampx nodeknockout})
      user.save
      expect(user.reload.redemptions).to eq(%w{railscampx nodeknockout})
    end

    it "should allow you to add a redemption" do
      user = Fabricate.build(:user, redemptions: %w{foo})
      user.update_attributes redemptions: %w{bar}
      expect(user.reload.redemptions).to eq(%w{bar})
    end

    it "should allow you to remove redemptions" do
      user = Fabricate.build(:user, redemptions: %w{foo})
      user.update_attributes redemptions: []
      expect(user.reload.redemptions).to be_empty
    end
  end

  describe "validation" do
    it "should not allow a username in the reserved list" do
      User::RESERVED.each do |reserved|
        user = Fabricate.build(:user, username: reserved)
        expect(user).not_to be_valid
        expect(user.errors[:username]).to eq(["is reserved"])
      end
    end

    it "should not allow a username with a period character" do
      user = Fabricate.build(:user, username: "foo.bar")
      expect(user).not_to be_valid
      expect(user.errors[:username]).to eq(["must not contain a period"])
    end
  end

  describe 'score' do
    let(:user) { Fabricate(:user) }
    let(:endorser) { Fabricate(:user) }

    it 'calculates weight of badges' do
      expect(user.achievement_score).to eq(0)
      user.award(Cub.new(user))
      expect(user.achievement_score).to eq(1)
      user.award(Philanthropist.new(user))
      expect(user.achievement_score).to eq(4)
    end

    it 'should penalize by amount or 1' do
      user.award(Cub.new(user))
      expect(user.score).to eq(1)
      user.penalize!
      expect(user.reload.score).to eq(0)
      endorser.endorse(user, 'Ruby')
      endorser.endorse(user, 'C++')
      endorser.endorse(user, 'CSS')
      user.reload
      expect(user.score).to eq(0.16666666666666674)
      user.penalize!(0.3)
      expect(user.reload.score).to eq(0.866666666666667)
      user.penalize!(2.0)
      expect(user.reload.score).to eq(0)
    end
  end

  it 'should indicate when user is on a premium team' do
    team = Fabricate(:team, premium: true)
    team.add_user(user = Fabricate(:user))
    expect(user.on_premium_team?).to eq(true)
  end

  it 'should indicate a user not on a premium team when they dont belong to a team at all' do
    user = Fabricate(:user)
    expect(user.on_premium_team?).to eq(false)
  end

  it 'should not error if the users team has been deleted' do
    team = Fabricate(:team)
    user = Fabricate(:user)
    team.add_user(user)
    team.destroy
    expect(user.team).to be_nil
  end

  it 'can follow another user' do
    user = Fabricate(:user)
    other_user = Fabricate(:user)
    user.follow(other_user)
    expect(other_user.followed_by?(user)).to eq(true)

    expect(user.following?(other_user)).to eq(true)
  end

  it 'should pull twitter follow list and follow any users on our system' do
    expect(Twitter).to receive(:friend_ids).with(6271932).and_return(['1111', '2222'])

    user = Fabricate(:user, twitter_id: 6271932)
    other_user = Fabricate(:user, twitter_id: '1111')
    expect(user).not_to be_following(other_user)
    user.build_follow_list!

    expect(user).to be_following(other_user)
  end

  describe 'skills' do
    let(:user) { Fabricate(:user) }

    it 'prevents duplicate skills from being created' do
      user.add_skill('Ruby')
      user.add_skill('Ruby ')
      user.reload
      expect(user.skills.size).to eq(1)
    end

    it 'finds skill by name' do
      skill_created = user.add_skill('Ruby')
      expect(user.skill_for('ruby')).to eq(skill_created)
    end
  end

  describe 'api key' do
    let(:user) { Fabricate(:user) }

    it 'should assign and save an api_key if not exists' do
      api_key = user.api_key
      expect(api_key).not_to be_nil
      expect(api_key).to eq(user.api_key)
      user.reload
      expect(user.api_key).to eq(api_key)
    end

    it 'should assign a new api_key if the one generated already exists' do
      RandomSecure = double('RandomSecure')
      allow(RandomSecure).to receive(:hex).and_return("0b5c141c21c15b34")
      user2 = Fabricate(:user)
      api_key2 = user2.api_key
      user2.api_key = RandomSecure.hex(8)
      expect(user2.api_key).not_to eq(api_key2)
      api_key1 = user.api_key
      expect(api_key1).not_to eq(api_key2)
    end
  end

  describe 'feature highlighting' do
    let(:user) { Fabricate(:user) }

    it 'indicates when a user has not seen a feature' do
      expect(user.seen?('some_feature')).to eq(false)
    end

    it 'indicates when a user has seen a feature' do
      user.seen('some_feature')
      expect(user.seen?('some_feature')).to eq(true)
    end
  end

  describe 'following' do
    let(:user) { Fabricate(:user) }
    let(:followable) { Fabricate(:user) }

    it 'should follow another user only once' do
      expect(user.following_by_type(User.name).size).to eq(0)
      user.follow(followable)
      expect(user.following_by_type(User.name).size).to eq(1)
      user.follow(followable)
      expect(user.following_by_type(User.name).size).to eq(1)
    end
  end

  describe 'banning' do
    let(:user) { Fabricate(:user) }

    it "should respond to banned? public method" do
      expect(user.respond_to?(:banned?)).to be_truthy
    end

    it "should not default to banned" do
      expect(user.banned?).to eq(false)
    end

  end

end
