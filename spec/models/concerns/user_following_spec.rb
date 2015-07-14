require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {Fabricate(:user)}
  it 'should respond to instance methods' do
    expect(user).to respond_to :build_follow_list!
    expect(user).to respond_to :follow
    expect(user).to respond_to :member_of?
    expect(user).to respond_to :following_team?
    expect(user).to respond_to :follow_team!
    expect(user).to respond_to :unfollow_team!
    expect(user).to respond_to :teams_being_followed
    expect(user).to respond_to :following_users_ids
    expect(user).to respond_to :following_teams_ids
    expect(user).to respond_to :following_team_members_ids
    expect(user).to respond_to :following_networks_tags
    expect(user).to respond_to :following
    expect(user).to respond_to :following_in_common
    expect(user).to respond_to :followed_repos
    expect(user).to respond_to :networks
    expect(user).to respond_to :followers_since
    expect(user).to respond_to :subscribed_to_topic?
    expect(user).to respond_to :subscribe_to
    expect(user).to respond_to :unsubscribe_from
    expect(user).to respond_to :protip_subscriptions
    expect(user).to respond_to :join
    expect(user).to respond_to :leave
  end


  describe 'following users' do
    let(:user) { Fabricate(:user) }
    let(:other_user) { Fabricate(:user) }

    it 'can follow another user' do
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

    it 'should follow another user only once' do
      expect(user.following_by_type(User.name).size).to eq(0)
      2.times do
        user.follow(other_user)
        expect(user.following_by_type(User.name).size).to eq(1)
      end
    end
  end

  describe 'following teams' do
    let(:user) { Fabricate(:user) }
    let(:team) { Fabricate(:team) }

    it 'can follow a team' do
      user.follow_team!(team)
      user.reload
      expect(user.following_team?(team)).to eq(true)
    end

    it 'can unfollow a team' do
      user.follow_team!(team)
      user.unfollow_team!(team)
      user.reload
      expect(user.following_team?(team)).to eq(false)
    end
  end

end
