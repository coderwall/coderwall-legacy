RSpec.describe 'Services::Search::' do

  describe 'ReindexProtip' do
    before { Protip.rebuild_index }

    it 'should add a users protip to the search index' do
      protip = Fabricate(:protip, body: 'something to ignore', title: "look at this content #{r = rand(100)}", user: Fabricate(:user))
      Services::Search::DeindexProtip.run(protip)
      expect(Protip.search('this content').count).to eq(0)

      Services::Search::ReindexProtip.run(protip)
      expect(Protip.search('this content').count).to eq(1)
    end

    it 'should not add a users protip to search index if user is banned' do
      user = Fabricate(:user,banned_at: Time.now)
      protip = Fabricate(:protip, body: "Some body.", title: "Some title.", user: user)
      expect(Protip.search('Some title').count).to eq(0)
    end
  end

  describe 'DeindexProtip' do
    before { Protip.rebuild_index }

    it 'should remove a users protip from search index' do
      protip = Fabricate(:protip, body: 'something to ignore', title: "look at this content #{r = rand(100)}", user: Fabricate(:user))
      expect(Protip.search('this content').count).to eq(1)
      Services::Search::DeindexProtip.run(protip)
      expect(Protip.search('this content').count).to eq(0)
    end
  end

end
