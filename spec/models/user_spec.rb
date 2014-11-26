RSpec.describe User, type: :model do
  it { is_expected.to have_one :github_profile }
  it { is_expected.to have_many :github_repositories }

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
    Fabricate(:user, username: 'MDEITERS')
    lambda do
      expect(Fabricate(:user, username: 'mdeiters')).to raise_error('Validation failed: Username has already been taken')
    end
  end

  it 'should find user by username no matter the case' do
    user = Fabricate(:user, username: 'seuros')
    expect(User.find_by_username('Seuros')).to eq(user)
  end

  it 'should not return incorrect user because of pattern matching' do
    user = Fabricate(:user, username: 'MDEITERS')
    found = User.find_by_username('M_EITERS')
    expect(found).not_to eq(user)
  end

  it 'should find users by username when provider is blank' do
    user = Fabricate(:user, username: 'mdeiters')
    expect(User.find_by_username('mdeiters', '')).to eq(user)
    expect(User.find_by_username('mdeiters', nil)).to eq(user)
  end

  it 'should find users ignoring case' do
    user = Fabricate(:user, username: 'MDEITERS', twitter: 'MDEITERS', github: 'MDEITERS', linkedin: 'MDEITERS')
    expect(User.find_by_username('mdeiters')).to eq(user)
    expect(User.find_by_username('mdeiters', :twitter)).to eq(user)
    expect(User.find_by_username('mdeiters', :github)).to eq(user)
    expect(User.find_by_username('mdeiters', :linkedin)).to eq(user)
  end

  it 'should return users with most badges' do
    user_with_2_badges = Fabricate :user, username: 'somethingelse'
    badge1 = user_with_2_badges.badges.create!(badge_class_name: Mongoose3.name)
    badge2 = user_with_2_badges.badges.create!(badge_class_name: Octopussy.name)

    user_with_3_badges = Fabricate :user
    badge1 = user_with_3_badges.badges.create!(badge_class_name: Mongoose3.name)
    badge2 = user_with_3_badges.badges.create!(badge_class_name: Octopussy.name)
    user_with_3_badges.badges.create!(badge_class_name: Mongoose.name)

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
    user.badges.create!(badge_class_name: Octopussy.name)
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
    omniauth = { 'info' => { 'name' => 'Matthew Deiters', 'urls' => { 'Blog' => 'http://www.theagiledeveloper.com', 'GitHub' => 'http://github.com/mdeiters' }, 'nickname' => 'mdeiters', 'email' => '' }, 'uid' => 7330, 'credentials' => { 'token' => 'f0f6946eb12c4156a7a567fd73aebe4d3cdde4c8' }, 'extra' => { 'user_hash' => { 'plan' => { 'name' => 'micro', 'collaborators' => 1, 'space' => 614_400, 'private_repos' => 5 }, 'gravatar_id' => 'aacb7c97f7452b3ff11f67151469e3b0', 'company' => nil, 'name' => 'Matthew Deiters', 'created_at' => '2008/04/14 15:53:10 -0700', 'location' => '', 'disk_usage' => 288_049, 'collaborators' => 0, 'public_repo_count' => 18, 'public_gist_count' => 31, 'blog' => 'http://www.theagiledeveloper.com', 'following_count' => 27, 'id' => 7330, 'owned_private_repo_count' => 2, 'private_gist_count' => 2, 'type' => 'User', 'permission' => nil, 'total_private_repo_count' => 2, 'followers_count' => 19, 'login' => 'mdeiters', 'email' => '' } }, 'provider' => 'github' }

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

  describe 'redemptions' do
    it 'should have an empty list of redemptions when new' do
      expect(Fabricate.build(:user).redemptions).to be_empty
    end

    it 'should have a single redemption with a redemptions list of one item' do
      user = Fabricate.build(:user, redemptions: %w(railscampx nodeknockout))
      user.save
      expect(user.reload.redemptions).to eq(%w(railscampx nodeknockout))
    end

    it 'should allow you to add a redemption' do
      user = Fabricate.build(:user, redemptions: %w(foo))
      user.update_attributes redemptions: %w(bar)
      expect(user.reload.redemptions).to eq(%w(bar))
    end

    it 'should allow you to remove redemptions' do
      user = Fabricate.build(:user, redemptions: %w(foo))
      user.update_attributes redemptions: []
      expect(user.reload.redemptions).to be_empty
    end
  end

  describe 'validation' do
    it 'should not allow a username in the reserved list' do
      User::RESERVED.each do |reserved|
        user = Fabricate.build(:user, username: reserved)
        expect(user).not_to be_valid
        expect(user.errors[:username]).to eq(['is reserved'])
      end
    end

    it 'should not allow a username with a period character' do
      user = Fabricate.build(:user, username: 'foo.bar')
      expect(user).not_to be_valid
      expect(user.errors[:username]).to eq(['must not contain a period'])
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
    member = team.add_member(user = Fabricate(:user))

    expect(user.on_premium_team?).to eq(true)
  end

  it 'should indicate a user not on a premium team when they dont belong to a team at all' do
    user = Fabricate(:user)
    expect(user.on_premium_team?).to eq(false)
  end

  it 'should not error if the users team has been deleted' do
    team = Fabricate(:team)
    user = Fabricate(:user)
    team.add_member(user)
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
    expect(Twitter).to receive(:friend_ids).with(6_271_932).and_return(%w(1111 2222))

    user = Fabricate(:user, twitter_id: 6_271_932)
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
      allow(RandomSecure).to receive(:hex).and_return('0b5c141c21c15b34')
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

   it 'should respond to banned? public method' do
     expect(user.respond_to?(:banned?)).to be_truthy
   end

   it 'should not default to banned' do
     expect(user.banned?).to eq(false)
   end
 end

  describe 'deleting a user' do
    it 'deletes asosciated protips' do
      user = Fabricate(:user)
      Fabricate(:protip, user: user)

      expect(user.reload.protips).to receive(:destroy_all).and_return(false)
      user.destroy
    end
  end

end
