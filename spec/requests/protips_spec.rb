RSpec.describe 'Viewing a protip', type: :request do

  describe 'when user coming from topic page' do
    let(:topic) { 'Ruby' }

    before :each do
      Protip.rebuild_index
      @protip1 = Fabricate(:protip, topics: topic, user: Fabricate(:user))
      @protip2 = Fabricate(:protip, topics: topic, user: Fabricate(:user))
      @protip3 = Fabricate(:protip, topics: topic, user: Fabricate(:user))
    end

    it 'returns them to the topic page when they use :back', skip: 'obsolete?' do
      visit tagged_protips_path(tags: topic)

      # save_and_open_page
      click_link @protip1.title
      expect(page).to have_content(@protip1.title)

      click_link 'Back'
      expect(page).to have_content(@protip1.title)
      expect(page).to have_content(@protip2.title)
      expect(page).to have_content(@protip3.title)
    end

    it 'has a link that takes them to next protip in topic page if there is one', search: true, skip: 'obsolete?' do
      visit tagged_protips_path(tags: topic)

      click_link @protip1.title
      # save_and_open_page
      expect(page).to have_content(@protip1.title)
      expect(page).to have_content(protip_path(@protip2))
      expect(page).not_to have_content(protip_path(@protip3))

      click_link @protip2.title
      expect(page).not_to have_content(@protip1.title)
    end
  end

end
