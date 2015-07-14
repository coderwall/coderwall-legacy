require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {Fabricate(:user)}
  it 'should respond to instance methods' do
    expect(user).to respond_to :clear_github!
    expect(user).to respond_to :build_github_proptips_fast
    expect(user).to respond_to :build_repo_followed_activity!
  end

  it 'should clear github' do
    user.clear_github!
    expect(user.github_id).to be_nil
    expect(user.github).to be_nil
    expect(user.github_token).to be_nil
    expect(user.joined_github_on).to be_nil
    expect(user.github_failures).to be_zero
  end
end
