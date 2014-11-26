require 'rails_helper'

feature 'Custom 404 Page', skip: true do
  before(:all) do
    Rails.application.config.action_dispatch.show_exceptions = true
    Rails.application.config.consider_all_requests_local = false
  end

  after(:all) do
    Rails.application.config.action_dispatch.show_exceptions = false
    Rails.application.config.consider_all_requests_local = true
  end

  scenario 'user is presented 404 page when they visit invalid path' do
    visit '/fake/path/doesnt/match/route'

    expect(page).to have_content('Uh oh, something went wrong!')
  end

  scenario 'user is presented 404 page when then visit a bad user path' do
    visit '/not_a_real_username'

    expect(page).to have_content('Uh oh, something went wrong!')
  end
end
