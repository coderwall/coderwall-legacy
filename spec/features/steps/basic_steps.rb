step 'I am logged in as :name with email :email' do |name, email|
  login_as(username: name, email: email, bypass_ui_login: true)
  @logged_in_user = User.where(username: name).first
end

step 'I go/am to/on page for :pupropse' do |purpose|
  path = case purpose
         when 'team management' then team_path(@logged_in_user.reload.team)
         end

  visit path
end

step 'show me the page' do
  page.save_screenshot('tmp/screenshot.png', full: true)
end

step 'I click :link_name' do |name|
  click_link name
end

step 'I am an administrator' do
  @logged_in_user.admin = true
  @logged_in_user.save
end

step 'I should see :text' do |text|
  expect(page).to have_content(text)
end

step 'I should see:' do |table|
  table.hashes.each do |text|
    expect(page).to have_content(text.values.first)
  end
end

step 'the last email should contain:' do |table|
  mail = ActionMailer::Base.deliveries.last

  table.hashes.each do |text|
    expect(mail).to have_content(text.values.first)
  end
end
