require 'rails_helper'

RSpec.describe User, type: :model do

  let(:user) {Fabricate(:user)}
  it 'should respond to methods' do
    expect(user).to respond_to :award
    expect(user).to respond_to :add_all_github_badges
    expect(user).to respond_to :remove_all_github_badges
    expect(user).to respond_to :award_and_add_skill
    expect(user).to respond_to :assign_badges
  end

  describe 'badges and award' do
    it 'should return users with most badges' do
      user_with_2_badges = Fabricate :user, username: 'somethingelse'
      user_with_2_badges.badges.create!(badge_class_name: Mongoose3.name)
      user_with_2_badges.badges.create!(badge_class_name: Octopussy.name)

      user_with_3_badges = Fabricate :user
      user_with_3_badges.badges.create!(badge_class_name: Mongoose3.name)
      user_with_3_badges.badges.create!(badge_class_name: Octopussy.name)
      user_with_3_badges.badges.create!(badge_class_name: Mongoose.name)

      expect(User.top(1)).to include(user_with_3_badges)
      expect(User.top(1)).not_to include(user_with_2_badges)
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
      user.award(NotaBadge.new(user))
      expect(user.badges.size).to eq(1)
      expect(user.badges.first.badge_class_name).to eq(NotaBadge.name)
    end

    it 'should not allow adding the same badge twice' do
      user.award(NotaBadge.new(user))
      user.award(NotaBadge.new(user))
      user.save!
      expect(user.badges.count).to eq(1)
    end

    it 'increments the badge count when you add new badges' do
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
      user.award(NotaBadge.new(user))
      user.award(NotaBadge.new(user))
      user.save!

      user2 = Fabricate(:user, username: 'different', github_token: 'unique')

      4.times do
        expect(User.random).not_to eq(user2)
      end
    end
  end

end