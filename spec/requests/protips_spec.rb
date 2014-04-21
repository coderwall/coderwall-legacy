describe "Viewing a protip" do

  describe 'when user coming from topic page' do
    let(:topic) { 'Ruby' }

    before :each do
      Protip.rebuild_index
      @protip1 = Fabricate(:protip, topics: topic, user: Fabricate(:user))
      @protip2 = Fabricate(:protip, topics: topic, user: Fabricate(:user))
      @protip3 = Fabricate(:protip, topics: topic, user: Fabricate(:user))
    end

    it 'returns them to the topic page when they use :back', pending: 'obsolete?' do
      visit tagged_protips_path(tags: topic)

      #save_and_open_page
      click_link @protip1.title
      page.should have_content(@protip1.title)

      click_link 'Back'
      page.should have_content(@protip1.title)
      page.should have_content(@protip2.title)
      page.should have_content(@protip3.title)
    end

    it 'has a link that takes them to next protip in topic page if there is one', search: true, pending: 'obsolete?' do
      visit tagged_protips_path(tags: topic)

      click_link @protip1.title
      #save_and_open_page
      page.should have_content(@protip1.title)
      page.should have_content(protip_path(@protip2))
      page.should_not have_content(protip_path(@protip3))

      click_link @protip2.title
      page.should_not have_content(@protip1.title)
    end
  end

end
