require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {Fabricate(:user)}
  it 'should respond to instance methods' do
    expect(user).to respond_to :team
    expect(user).to respond_to :team_member_ids
    expect(user).to respond_to :on_team?
    expect(user).to respond_to :team_member_of?
    expect(user).to respond_to :belongs_to_team?
  end

  describe '#team' do
    let(:team) { Fabricate(:team) }
    let(:user) { Fabricate(:user) }

    it 'returns membership team if user has membership' do
      team.add_member(user)
      expect(user.team).to eq(team)
    end

    it 'returns team if team_id is set' do
      user.team_id = team.id
      user.save
      expect(user.team).to eq(team)
    end

    it 'returns nil if no team_id or membership' do
      expect(user.team).to eq(nil)
    end

    it 'should not error if the users team has been deleted' do
      team = Fabricate(:team)
      user = Fabricate(:user)
      team.add_member(user)
      team.destroy
      expect(user.team).to be_nil
    end
  end

  describe '#on_team?' do
    let(:team) { Fabricate(:team) }
    let(:user) { Fabricate(:user) }

    it 'is true if user has a membership' do
      expect(user.on_team?).to eq(false)
      team.add_member(user)
      expect(user.reload.on_team?).to eq(true)
    end

    it 'is true if user is on a team' do
      expect(user.on_team?).to eq(false)
      user.team = team
      user.save
      expect(user.reload.on_team?).to eq(true)
    end
  end


  describe "#on_premium_team?" do
    it 'should indicate when user is on a premium team' do
      team = Fabricate(:team, premium: true)
      member = team.add_member(user = Fabricate(:user))
      expect(user.on_premium_team?).to eq(true)
    end

    it 'should indicate a user not on a premium team when they dont belong to a team at all' do
      user = Fabricate(:user)
      expect(user.on_premium_team?).to eq(false)
    end
  end

end
