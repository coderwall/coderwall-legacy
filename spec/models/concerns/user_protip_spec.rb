require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {Fabricate(:user)}
  it 'should respond to instance methods' do
    expect(user).to respond_to :upvoted_protips
    expect(user).to respond_to :upvoted_protips_public_ids
    expect(user).to respond_to :bookmarked_protips
    expect(user).to respond_to :authored_protips
    expect(user).to respond_to :owned_by?
    expect(user).to respond_to :owner?
  end
end
