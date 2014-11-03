module Features
  module GeneralHelpers
    def login_as(settings = {})
      settings.reverse_merge!({
        username: 'test_user',
        email: 'test_user@test.com',
        location: 'Iceland',
        bypass_ui_login: false,
      })

      if settings[:bypass_ui_login]
        settings.delete(:bypass_ui_login)

        user = User.create(settings)
        page.set_rack_session(current_user: user.id)
      else
        visit "/auth/developer"

        fill_in 'name', with: settings[:username]
        fill_in 'email', with: settings[:email]
        click_button 'Sign In'

        fill_in 'user_username', with: settings[:username]
        fill_in 'user_location', with: settings[:location]
        click_button 'Finish'
      end

      user
    end

    def create_team(name = 'TEST_TEAM')
      visit '/employers'
      fill_in 'team_name', with: name
      click_button 'Next'
    end
  end
end
