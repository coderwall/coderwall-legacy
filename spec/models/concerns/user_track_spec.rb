require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {Fabricate(:user)}
  it 'should respond to instance methods' do
    expect(user).to respond_to :track!
    expect(user).to respond_to :track_user_view!
    expect(user).to respond_to :track_signin!
    expect(user).to respond_to :track_viewed_self!
    expect(user).to respond_to :track_team_view!
    expect(user).to respond_to :track_protip_view!
    expect(user).to respond_to :track_opportunity_view!
  end

  describe '#track' do
    it 'should use track!' do
      name = FFaker::Internet.user_name
      user.track!(name)
      expect(user.user_events.count).to eq(1)
    end
    it 'should use track_user_view!' do
      user.track_user_view!(user)
      expect(user.user_events.count).to eq(1)
    end
    it 'should use track_signin!' do
      user.track_signin!
      expect(user.user_events.count).to eq(1)
    end
    it 'should use track_viewed_self!' do
      user.track_viewed_self!
      expect(user.user_events.count).to eq(1)
    end
    it 'should use track_team_view!' do
      team=Fabricate(:team)
      user.track_team_view!(team)
      expect(user.user_events.count).to eq(1)
    end
    it 'should use track_protip_view!' do
      protip=Fabricate(:protip)
      user.track_protip_view!(protip)
      expect(user.user_events.count).to eq(1)
    end
    # xit 'should use track_opportunity_view!' do
    #   opportunity=Fabricate(:opportunity)
    #   user.track_opportunity_view!(opportunity)
    #   expect(user.user_events.count).to eq(1)
    # end
  end
end
