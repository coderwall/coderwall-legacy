RSpec.describe ActivateUser,  functional: true do
  it 'should activate a user regardless of achievements by default', slow: true do
    user = Fabricate(:pending_user, github: 'hirelarge')
    ActivateUser.new(user.username).perform
    expect(user.reload).to be_active
  end

  it 'should not activate a user if no achievements and only_if_achievements flag is true', slow: true do
    user = Fabricate(:pending_user, github: 'hirelarge')
    ActivateUser.new(user.username, always_activate=false).perform
    expect(user.reload).not_to be_active
  end

  it 'should activate a user if achievements even if only_if_achievements flag is true', slow: true do
    user = Fabricate(:pending_user, github: 'mdeiters')
    ActivateUser.new(user.username).perform
    expect(user.reload).to be_active
  end
end
