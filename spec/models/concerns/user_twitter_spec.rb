require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {Fabricate(:user)}
  it 'should respond to instance methods' do
    expect(user).to respond_to :clear_twitter!
  end

  it 'should clear twitter' do
    user.clear_twitter!
    expect(user.twitter).to be_nil
    expect(user.twitter_token).to be_nil
    expect(user.twitter_secret).to be_nil
  end
end
