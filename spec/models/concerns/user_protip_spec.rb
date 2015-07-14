require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {Fabricate(:user)}
  it 'should respond to instance methods' do
    expect(user).to respond_to :upvoted_protips
    expect(user).to respond_to :upvoted_protips_public_ids
    expect(user).to respond_to :bookmarked_protips
    expect(user).to respond_to :authored_protips
  end

  describe 'deleting a user' do
    it 'deletes asosciated protips' do
      user = Fabricate(:user)
      Fabricate(:protip, user: user)

      expect(user.reload.protips).to receive(:destroy_all).and_return(false)
      user.destroy
    end
  end
end
