require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {Fabricate(:user)}
  it 'should respond to instance methods' do
    expect(user).to respond_to :has_badges?
    expect(user).to respond_to :total_achievements
    expect(user).to respond_to :achievement_score
    expect(user).to respond_to :achievements_unlocked_since_last_visit
    expect(user).to respond_to :oldest_achievement_since_last_visit
    expect(user).to respond_to :check_achievements!
  end

  describe '#has_badges' do
    xit 'return nil if no badge is present' do
      expect(user.has_badges?).to eq(0)
    end
    xit 'return identity if badge is present' do
      BadgeBase.new(user)
     user.badges.build
      expect(user.has_badges?).to eq(1)
    end
  end
end
