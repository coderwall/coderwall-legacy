require 'vcr_helper'

#RSpec.describe ActivateUserJob, functional: true , skip: ENV['TRAVIS'] do
#  it 'should activate a user regardless of achievements by default', slow: true do
#    user = Fabricate(:pending_user, github: 'hirelarge')
#    ActivateUserJob.new(user.username).perform
#    expect(user.reload).to be_active
#  end

#  it 'should not activate a user if no achievements and only_if_achievements flag is true', slow: true do
#    user = Fabricate(:pending_user, github: 'hirelarge')
#    ActivateUserJob.new(user.username, always_activate=false).perform
#    expect(user.reload).not_to be_active
#  end

#  it 'should activate a user if achievements even if only_if_achievements flag is true', slow: true do
#    user = Fabricate(:pending_user, github: 'mdeiters')
#    ActivateUserJob.new(user.username).perform
#    expect(user.reload).to be_active
#  end
#end
