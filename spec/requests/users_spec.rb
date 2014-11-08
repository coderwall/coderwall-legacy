RSpec.describe "User management", :type => :request do

  describe 'deleting a user' do
    it 'deletes associated protips and reindex search index' do
      user = Fabricate(:user)

      Protip.rebuild_index
      protip_1, protip_2 = Fabricate.times(2, :protip, user: user)
      protip_3 = Fabricate(:protip)

      user.reload.destroy
      search = Protip.search('*').map(&:title)

      expect(search).not_to include(protip_1.title)
      expect(search).not_to include(protip_2.title)
      expect(search).to include(protip_3.title)
    end
  end

end
