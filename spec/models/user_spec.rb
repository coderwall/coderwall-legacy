# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `users`
#
# ### Columns
#
# Name                                 | Type               | Attributes
# ------------------------------------ | ------------------ | ---------------------------
# **`about`**                          | `text`             |
# **`achievements_checked_at`**        | `datetime`         | `default(1914-02-20 22:39:10 UTC)`
# **`activated_on`**                   | `datetime`         |
# **`admin`**                          | `boolean`          | `default(FALSE)`
# **`api_key`**                        | `string(255)`      |
# **`avatar`**                         | `string(255)`      |
# **`backup_email`**                   | `string(255)`      |
# **`badges_count`**                   | `integer`          | `default(0)`
# **`banner`**                         | `string(255)`      |
# **`beta_access`**                    | `boolean`          | `default(FALSE)`
# **`bitbucket`**                      | `string(255)`      |
# **`blog`**                           | `string(255)`      |
# **`city`**                           | `string(255)`      |
# **`claim_code`**                     | `text`             |
# **`codeplex`**                       | `string(255)`      |
# **`company`**                        | `string(255)`      |
# **`country`**                        | `string(255)`      |
# **`created_at`**                     | `datetime`         |
# **`dribbble`**                       | `string(255)`      |
# **`email`**                          | `string(255)`      |
# **`endorsements_count`**             | `integer`          | `default(0)`
# **`favorite_websites`**              | `string(255)`      |
# **`forrst`**                         | `string(255)`      |
# **`github`**                         | `string(255)`      |
# **`github_failures`**                | `integer`          | `default(0)`
# **`github_id`**                      | `integer`          |
# **`github_token`**                   | `string(255)`      |
# **`google_code`**                    | `string(255)`      |
# **`http_counter`**                   | `integer`          |
# **`id`**                             | `integer`          | `not null, primary key`
# **`ip_lat`**                         | `float`            |
# **`ip_lng`**                         | `float`            |
# **`join_badge_orgs`**                | `boolean`          | `default(FALSE)`
# **`joined_github_on`**               | `date`             |
# **`joined_twitter_on`**              | `date`             |
# **`last_asm_email_at`**              | `datetime`         |
# **`last_email_sent`**                | `datetime`         |
# **`last_refresh_at`**                | `datetime`         | `default(1970-01-01 00:00:00 UTC)`
# **`last_request_at`**                | `datetime`         |
# **`lat`**                            | `float`            |
# **`linkedin`**                       | `string(255)`      |
# **`linkedin_id`**                    | `string(255)`      |
# **`linkedin_legacy`**                | `string(255)`      |
# **`linkedin_public_url`**            | `string(255)`      |
# **`linkedin_secret`**                | `string(255)`      |
# **`linkedin_token`**                 | `string(255)`      |
# **`lng`**                            | `float`            |
# **`location`**                       | `string(255)`      |
# **`login_count`**                    | `integer`          | `default(0)`
# **`name`**                           | `string(255)`      |
# **`notify_on_award`**                | `boolean`          | `default(TRUE)`
# **`notify_on_follow`**               | `boolean`          | `default(TRUE)`
# **`old_github_token`**               | `string(255)`      |
# **`penalty`**                        | `float`            | `default(0.0)`
# **`receive_newsletter`**             | `boolean`          | `default(TRUE)`
# **`receive_weekly_digest`**          | `boolean`          | `default(TRUE)`
# **`redemptions`**                    | `text`             |
# **`referral_token`**                 | `string(255)`      |
# **`referred_by`**                    | `string(255)`      |
# **`remind_to_create_protip`**        | `datetime`         |
# **`remind_to_create_skills`**        | `datetime`         |
# **`remind_to_create_team`**          | `datetime`         |
# **`remind_to_invite_team_members`**  | `datetime`         |
# **`remind_to_link_accounts`**        | `datetime`         |
# **`resume`**                         | `string(255)`      |
# **`score_cache`**                    | `float`            | `default(0.0)`
# **`slideshare`**                     | `string(255)`      |
# **`sourceforge`**                    | `string(255)`      |
# **`speakerdeck`**                    | `string(255)`      |
# **`specialties`**                    | `text`             |
# **`stackoverflow`**                  | `string(255)`      |
# **`state`**                          | `string(255)`      |
# **`state_name`**                     | `string(255)`      |
# **`team_avatar`**                    | `string(255)`      |
# **`team_banner`**                    | `string(255)`      |
# **`team_document_id`**               | `string(255)`      |
# **`team_responsibilities`**          | `text`             |
# **`thumbnail_url`**                  | `text`             |
# **`title`**                          | `string(255)`      |
# **`tracking_code`**                  | `string(255)`      |
# **`twitter`**                        | `string(255)`      |
# **`twitter_checked_at`**             | `datetime`         | `default(1914-02-20 22:39:10 UTC)`
# **`twitter_id`**                     | `string(255)`      |
# **`twitter_secret`**                 | `string(255)`      |
# **`twitter_token`**                  | `string(255)`      |
# **`updated_at`**                     | `datetime`         |
# **`username`**                       | `string(255)`      |
# **`utm_campaign`**                   | `string(255)`      |
# **`visit_frequency`**                | `string(255)`      | `default("rarely")`
# **`visits`**                         | `string(255)`      | `default("")`
# **`zerply`**                         | `string(255)`      |
#
# ### Indexes
#
# * `index_users_on_github_token` (_unique_):
#     * **`old_github_token`**
# * `index_users_on_linkedin_id` (_unique_):
#     * **`linkedin_id`**
# * `index_users_on_team_document_id`:
#     * **`team_document_id`**
# * `index_users_on_twitter_id` (_unique_):
#     * **`twitter_id`**
# * `index_users_on_username` (_unique_):
#     * **`username`**
#

require 'spec_helper'

describe User do
  before :each do
    User.destroy_all
  end

  describe 'viewing' do
    it 'tracks when a user views a profile' do
      user = Fabricate :user
      viewer = Fabricate :user
      user.viewed_by(viewer)
      user.viewers.first.should == viewer
      user.total_views.should == 1
    end

    it 'tracks when a user views a profile' do
      user = Fabricate :user
      user.viewed_by(nil)
      user.total_views.should == 1
    end
  end

  it 'should create a token on creation' do
    user = Fabricate(:user)
    user.referral_token.should_not be_nil
  end

  it 'should not allow the username in multiple cases to be use on creation' do
    user = Fabricate(:user, username: 'MDEITERS')
    lambda {
      Fabricate(:user, username: 'mdeiters').should raise_error('Validation failed: Username has already been taken')
    }
  end

  it 'should not return incorrect user because of pattern matching' do
    user = Fabricate(:user, username: 'MDEITERS')
    found = User.with_username('M_EITERS')
    found.should_not == user
  end

  it 'should find users by username when provider is blank' do
    user = Fabricate(:user, username: 'mdeiters')
    User.with_username('mdeiters', '').should == user
    User.with_username('mdeiters', nil).should == user
  end

  it 'should find users ignoring case' do
    user = Fabricate(:user, username: 'MDEITERS', twitter: 'MDEITERS', github: 'MDEITERS', linkedin: 'MDEITERS')
    User.with_username('mdeiters').should == user
    User.with_username('mdeiters', :twitter).should == user
    User.with_username('mdeiters', :github).should == user
    User.with_username('mdeiters', :linkedin).should == user
  end

  it 'should return users with most badges' do
    user_with_2_badges = Fabricate :user, username: 'somethingelse'
    badge1 = user_with_2_badges.badges.create!(badge_class_name: Mongoose3.name)
    badge2 = user_with_2_badges.badges.create!(badge_class_name: Octopussy.name)

    user_with_3_badges = Fabricate :user
    badge1 = user_with_3_badges.badges.create!(badge_class_name: Mongoose3.name)
    badge2 = user_with_3_badges.badges.create!(badge_class_name: Octopussy.name)
    badge3 = user_with_3_badges.badges.create!(badge_class_name: Mongoose.name)

    User.top(1).should include(user_with_3_badges)
    User.top(1).should_not include(user_with_2_badges)
  end

  it 'should require valid email when instantiating' do
    u = Fabricate.build(:user, email: 'someting @ not valid.com', state: nil)
    u.save.should be_false
    u.should_not be_valid
    u.errors[:email].should_not be_empty
  end

  it 'returns badges in order created with latest first' do
    user = Fabricate :user
    badge1 = user.badges.create!(badge_class_name: Mongoose3.name)
    badge2 = user.badges.create!(badge_class_name: Octopussy.name)
    badge3 = user.badges.create!(badge_class_name: Mongoose.name)

    user.badges.first.should == badge3
    user.badges.last.should == badge1
  end

  class NotaBadge < BadgeBase
  end

  class AlsoNotaBadge < BadgeBase
  end

  it 'should award user with badge' do
    user = Fabricate :user
    user.award(NotaBadge.new(user))
    user.badges.should have(1).badge
    user.badges.first.badge_class_name.should == NotaBadge.name
  end

  it 'instantiates new user with omniauth if the user is not on file' do
    omniauth = {"info" => {"name" => "Matthew Deiters", "urls" => {"Blog" => "http://www.theagiledeveloper.com", "GitHub" => "http://github.com/mdeiters"}, "nickname" => "mdeiters", "email" => ""}, "uid" => 7330, "credentials" => {"token" => "f0f6946eb12c4156a7a567fd73aebe4d3cdde4c8"}, "extra" => {"user_hash" => {"plan" => {"name" => "micro", "collaborators" => 1, "space" => 614400, "private_repos" => 5}, "gravatar_id" => "aacb7c97f7452b3ff11f67151469e3b0", "company" => nil, "name" => "Matthew Deiters", "created_at" => "2008/04/14 15:53:10 -0700", "location" => "", "disk_usage" => 288049, "collaborators" => 0, "public_repo_count" => 18, "public_gist_count" => 31, "blog" => "http://www.theagiledeveloper.com", "following_count" => 27, "id" => 7330, "owned_private_repo_count" => 2, "private_gist_count" => 2, "type" => "User", "permission" => nil, "total_private_repo_count" => 2, "followers_count" => 19, "login" => "mdeiters", "email" => ""}}, "provider" => "github"}

    user = User.for_omniauth(omniauth.with_indifferent_access)
    user.should be_new_record
  end

  it 'increments the badge count when you add new badges' do
    user = Fabricate :user

    user.award(NotaBadge.new(user))
    user.save!
    user.reload
    user.badges_count.should == 1

    user.award(AlsoNotaBadge.new(user))
    user.save!
    user.reload
    user.badges_count.should == 2
  end

  it 'should randomly select the user with badges' do
    user = Fabricate :user
    user.award(NotaBadge.new(user))
    user.award(NotaBadge.new(user))
    user.save!

    user2 = Fabricate :user, username: 'different', github_token: 'unique'

    4.times do
      User.random.should_not == user2
    end
  end

  it 'should not allow adding the same badge twice' do
    user = Fabricate :user
    user.award(NotaBadge.new(user))
    user.award(NotaBadge.new(user))
    user.save!
    user.badges.count.should == 1
  end

  describe "redemptions" do
    it "should have an empty list of redemptions when new" do
      Fabricate.build(:user).redemptions.should be_empty
    end

    it "should have a single redemption with a redemptions list of one item" do
      user = Fabricate.build(:user, redemptions: %w{railscampx nodeknockout})
      user.save
      user.reload.redemptions.should == %w{railscampx nodeknockout}
    end

    it "should allow you to add a redemption" do
      user = Fabricate.build(:user, redemptions: %w{foo})
      user.update_attributes redemptions: %w{bar}
      user.reload.redemptions.should == %w{bar}
    end

    it "should allow you to remove redemptions" do
      user = Fabricate.build(:user, redemptions: %w{foo})
      user.update_attributes redemptions: []
      user.reload.redemptions.should be_empty
    end
  end

  describe "validation" do
    it "should not allow a username in the reserved list" do
      User::RESERVED.each do |reserved|
        user = Fabricate.build(:user, username: reserved)
        user.should_not be_valid
        user.errors[:username].should == ["is reserved"]
      end
    end

    it "should not allow a username with a period character" do
      user = Fabricate.build(:user, username: "foo.bar")
      user.should_not be_valid
      user.errors[:username].should == ["must not contain a period"]
    end
  end

  describe 'score' do
    let(:user) { Fabricate(:user) }
    let(:endorser) { Fabricate(:user) }

    it 'calculates weight of badges' do
      user.achievement_score.should == 0
      user.award(Cub.new(user))
      user.achievement_score.should == 1
      user.award(Philanthropist.new(user))
      user.achievement_score.should == 4
    end

    it 'should penalize by amount or 1' do
      user.award(Cub.new(user))
      user.score.should == 1
      user.penalize!
      user.reload.score.should == 0
      endorser.endorse(user, 'Ruby')
      endorser.endorse(user, 'C++')
      endorser.endorse(user, 'CSS')
      user.reload
      user.score.should == 0.16666666666666674
      user.penalize!(0.3)
      user.reload.score.should == 0.866666666666667
      user.penalize!(2.0)
      user.reload.score.should == 0
    end
  end

  it 'should indicate when user is on a premium team' do
    team = Fabricate(:team, premium: true)
    team.add_user(user = Fabricate(:user))
    user.on_premium_team?.should == true
  end

  it 'should indicate a user not on a premium team when they dont belong to a team at all' do
    user = Fabricate(:user)
    user.on_premium_team?.should == false
  end

  it 'should not error if the users team has been deleted' do
    team = Fabricate(:team)
    user = Fabricate(:user)
    team.add_user(user)
    team.destroy
    user.team.should be_nil
  end

  it 'can follow another user' do
    user = Fabricate(:user)
    other_user = Fabricate(:user)
    user.follow(other_user)
    other_user.followed_by?(user).should == true

    user.following?(other_user).should == true
  end

  it 'should pull twitter follow list and follow any users on our system' do
    Twitter.should_receive(:friend_ids).with(6271932).and_return(['1111', '2222'])

    user = Fabricate(:user, twitter_id: 6271932)
    other_user = Fabricate(:user, twitter_id: '1111')
    user.should_not be_following(other_user)
    user.build_follow_list!

    user.should be_following(other_user)
  end

  describe 'skills' do
    let(:user) { Fabricate(:user) }

    it 'prevents duplicate skills from being created' do
      user.add_skill('Ruby')
      user.add_skill('Ruby ')
      user.reload
      user.should have(1).skill
    end

    it 'finds skill by name' do
      skill_created = user.add_skill('Ruby')
      user.skill_for('ruby').should == skill_created
    end
  end

  describe 'api key' do
    let(:user) { Fabricate(:user) }

    it 'should assign and save an api_key if not exists' do
      api_key = user.api_key
      api_key.should_not be_nil
      api_key.should == user.api_key
      user.reload
      user.api_key.should == api_key
    end

    it 'should assign a new api_key if the one generated already exists' do
      RandomSecure = double('RandomSecure')
      RandomSecure.stub(:hex).and_return("0b5c141c21c15b34")
      user2 = Fabricate(:user)
      api_key2 = user2.api_key
      user2.api_key = RandomSecure.hex(8)
      user2.api_key.should_not == api_key2
      api_key1 = user.api_key
      api_key1.should_not == api_key2
    end
  end

  describe 'feature highlighting' do
    let(:user) { Fabricate(:user) }

    it 'indicates when a user has not seen a feature' do
      user.seen?('some_feature').should == false
    end

    it 'indicates when a user has seen a feature' do
      user.seen('some_feature')
      user.seen?('some_feature').should == true
    end
  end

  describe 'following' do
    let(:user) { Fabricate(:user) }
    let(:followable) { Fabricate(:user) }

    it 'should follow another user only once' do
      user.following_by_type(User.name).size.should == 0
      user.follow(followable)
      user.following_by_type(User.name).size.should == 1
      user.follow(followable)
      user.following_by_type(User.name).size.should == 1
    end
  end
end
