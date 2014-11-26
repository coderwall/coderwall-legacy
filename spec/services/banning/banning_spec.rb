require 'spec_helper'

RSpec.describe 'Services::Banning::' do

  describe 'User' do
    let(:user) { Fabricate(:user) }

    it 'should ban a user ' do
      expect(user.banned?).to eq(false)
      Services::Banning::UserBanner.ban(user)
      expect(user.banned?).to eq(true)
    end

    it 'should unban a user' do
      Services::Banning::UserBanner.ban(user)
      expect(user.banned?).to eq(true)
      Services::Banning::UserBanner.unban(user)
      expect(user.banned?).to eq(false)
    end
  end

  describe 'DeindexUserProtips' do
    before(:each) do
      Protip.rebuild_index
    end

    it 'should deindex all of a users protips' do
      user = Fabricate(:user)
      protip_1 = Fabricate(:protip, body: 'First', title: 'look at this content 1', user: user)
      protip_2 = Fabricate(:protip, body: 'Second', title: 'look at this content 2', user: user)
      user.reload

      expect(Protip.search('this content').count).to eq(2)
      Services::Banning::DeindexUserProtips.run(user)
      expect(Protip.search('this content').count).to eq(0)
    end
  end

  describe 'IndexUserProtips' do
    before(:each) do
      Protip.rebuild_index
    end

    it 'should deindex all of a users protips' do
      user      = Fabricate(:user)
      protip_1  = Fabricate(:protip, body: 'First', title: 'look at this content 1', user: user)
      protip_2  = Fabricate(:protip, body: 'Second', title: 'look at this content 2', user: user)
      search    = lambda { Protip.search('this content') }
      user.reload

      Services::Banning::DeindexUserProtips.run(user)
      expect(search.call.count).to eq(0)
      Services::Banning::IndexUserProtips.run(user)
      expect(search.call.count).to eq(2)
    end
  end
end
