require 'spec_helper'

describe 'Services::Banning::' do

  describe 'User' do
    let(:user) { Fabricate(:user) }

    it "should ban a user " do
      user.banned?.should == false
      Services::Banning::UserBanner.ban(user)
      user.banned?.should == true
    end

    it "should unban a user" do
      Services::Banning::UserBanner.ban(user)
      user.banned?.should == true
      Services::Banning::UserBanner.unban(user)
      user.banned?.should == false
    end
  end

  describe "DeindexUserProtips" do
    before(:each) do
      Protip.rebuild_index
    end

    it "should deindex all of a users protips" do
      user = Fabricate(:user)
      protip_1 = Fabricate(:protip,body: "First", title: "look at this content 1", user: user)
      protip_2 = Fabricate(:protip,body: "Second", title: "look at this content 2", user: user)
      user.reload

      Protip.search("this content").count.should == 2
      Services::Banning::DeindexUserProtips.run(user)
      Protip.search("this content").count.should == 0
    end
  end

  describe "IndexUserProtips" do
    before(:each) do
      Protip.rebuild_index
    end

    it "should deindex all of a users protips" do
      user      = Fabricate(:user)
      protip_1  = Fabricate(:protip,body: "First", title: "look at this content 1", user: user)
      protip_2  = Fabricate(:protip,body: "Second", title: "look at this content 2", user: user)
      search    = lambda {Protip.search("this content")}
      user.reload

      Services::Banning::DeindexUserProtips.run(user)
      search.call.count.should == 0
      Services::Banning::IndexUserProtips.run(user)
      search.call.count.should == 2
    end
  end
end
