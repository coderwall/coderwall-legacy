require "rails_helper"

feature "User management", js: true do
  describe 'deleting a user' do
    before do
      stub_request(:post, /api.mixpanel.com/)
    end

    let!(:user) { login_as(username: 'alice', bypass_ui_login: true) }

    scenario 'user is presented with confirmation dialog when deletes his account' do
      visit '/settings'
      find('.delete').click_link 'click here.'

      expect(page).to have_content 'Warning: clicking this link below will permenatly delete your Coderwall account and its data.'
      expect(page).to have_button 'Delete your account & sign out'
    end

    scenario 'user is redirected to /welcome after deleting hios account' do
      visit '/settings'
      find('.delete').click_link 'click here.'
      find('.save').click_button 'Delete your account & sign out'

      expect(current_path).to eq('/welcome')
    end

    scenario 'user cannot login after deleting his account' do
      visit '/settings'
      find('.delete').click_link 'click here.'
      find('.save').click_button 'Delete your account & sign out'

      visit "/auth/developer"
      fill_in 'name', with: user.username
      fill_in 'email', with: user.email
      click_button 'Sign In'

      expect(current_path).to eq(new_user_path)
    end

    scenario 'users protips are not displayed after he deletes his account' do
      Protip.rebuild_index
      protip_1, protip_2 = Fabricate.times(2, :protip, user: user)
      protip_3 = Fabricate(:protip)

      visit '/settings'
      find('.delete').click_link 'click here.'
      find('.save').click_button 'Delete your account & sign out'

      login_as(username: 'bob', bypass_ui_login: true)
      visit '/p/fresh'

      expect(page).not_to have_content(protip_1.title)
      expect(page).not_to have_content(protip_2.title)
      expect(page).to have_content(protip_3.title)
    end
  end

end
