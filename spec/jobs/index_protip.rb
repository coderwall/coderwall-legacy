describe IndexProtip do

  before(:each) do
    Protip.rebuild_index
  end

  def deindex_protip(tip)
    Coderwall::Search::DeindexProtip.run(tip)
  end

  it 'job should index a protip' do
    user = Fabricate(:user)
    protip = Fabricate(:protip, body: 'something to ignore', title: "look at this content", user: user)
    deindex_protip(protip)
    Protip.search("this content").count.should == 0
    IndexProtip.new(protip.id).perform
    Protip.search("this content").count.should == 1
  end



end
