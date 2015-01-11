require 'spec_helper'

RSpec.describe Changelogd, type: :model do
  it 'should have a name and description' do
    expect(Changelogd.name).not_to be_blank
    expect(Changelogd.description).not_to be_blank
  end

  it 'is not awardable' do
    user = Fabricate(:user, github: 'codebender')
    expect(Changelogd.new(user).award?).to be false
  end
end
