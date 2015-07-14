require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {Fabricate(:user)}
  it 'should respond to instance methods' do
    expect(user).to respond_to :clear_linkedin!
  end

  it 'should clear linkedin' do
    user.clear_linkedin!
    expect(user.linkedin).to be_nil
    expect(user.linkedin_id).to be_nil
    expect(user.linkedin_token).to be_nil
    expect(user.linkedin_secret).to be_nil
    expect(user.linkedin_public_url).to be_nil
    expect(user.linkedin_legacy).to be_nil
  end
end
