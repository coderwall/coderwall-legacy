RSpec.describe IndexProtip do
  before { Protip.rebuild_index }

  def deindex_protip(tip)
    Services::Search::DeindexProtip.run(tip)
  end

  it 'job should index a protip' do
    user = Fabricate(:user)
    protip = Fabricate(:protip, body: 'something to ignore', title: "look at this content", user: user)
    deindex_protip(protip)
    expect(Protip.search("this content").count).to eq(0)
    IndexProtip.new(protip.id).perform
    expect(Protip.search("this content").count).to eq(1)
  end
end
