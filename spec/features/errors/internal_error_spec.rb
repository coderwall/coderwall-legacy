require 'rails_helper'

feature 'Custom 500 Page', skip: true do
  before(:all) do
    Rails.application.config.action_dispatch.show_exceptions = true
    Rails.application.config.consider_all_requests_local = false
  end

  after(:all) do
    Rails.application.config.action_dispatch.show_exceptions = false
    Rails.application.config.consider_all_requests_local = true
  end

  scenario 'User is presented 500 page when an exception is raised' do
    allow(User).to receive(:find_by_username!).and_raise(StandardError)

    visit '/user_causes_500_error'

    expect(page).
      to have_content('Coderwall had an issue but hold on to your localhosts')
  end
end
