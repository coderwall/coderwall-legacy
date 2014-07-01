require 'spec_helper'

describe "Coderwall::Search::" do

  describe "IndexProtip" do

    before(:each) do
      Protip.rebuild_index
    end

    it "should add a users protip to the search index" do
      protip = Fabricate(:protip, body: 'something to ignore', title: "look at this content #{r = rand(100)}", user: Fabricate(:user))
      Coderwall::Search::DeindexProtip.run(protip)
      Protip.search('this content').count.should == 0

      Coderwall::Search::IndexProtip.run(protip)
      Protip.search('this content').count.should == 1
    end

    it "should not add a users protip to search index if user is banned" do
      user = Fabricate(:user,banned_at: Time.now)
      protip = Fabricate(:protip, body: "Some body.", title: "Some title.", user: user)
      Protip.search('Some title').count.should == 0
    end
  end

  describe "DeindexProtip" do
    before(:each) do
      Protip.rebuild_index
    end

    it "should remove a users protip from search index" do
      protip = Fabricate(:protip, body: 'something to ignore', title: "look at this content #{r = rand(100)}", user: Fabricate(:user))
      Protip.search('this content').count.should == 1
      Coderwall::Search::DeindexProtip.run(protip)
      Protip.search('this content').count.should == 0
    end
  end

end
