RSpec.describe ProtipIndexer do
  before(:all) { Protip.rebuild_index }
  describe '#store' do
    it 'should add a users protip to the search index' do
      protip = Fabricate(:protip, body: 'something to ignore',
                         title: 'look at this content')
      ProtipIndexer.new(protip).remove
      expect(Protip.search('this content').count).to eq(0)
      ProtipIndexer.new(protip).store
      expect(Protip.search('this content').count).to eq(1)
    end

    it 'should not add a users protip to search index if user is banned' do
      banned_user = Fabricate(:user, banned_at: Time.now)
      Fabricate(:protip, body: "Some body.", title: "Some title.", user: banned_user)
      expect(Protip.search('Some title').count).to eq(0)
    end
  end

  describe '#remove' do
    it 'should remove a users protip from search index' do
      protip = Fabricate(:protip, body: 'something to ignore', title: 'look at that troll')
      expect(Protip.search('that troll').count).to eq(1)
      ProtipIndexer.new(protip).remove
      expect(Protip.search('that troll').count).to eq(0)
    end
  end
end