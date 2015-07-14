require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {Fabricate(:user)}
  it 'should respond to instance methods' do
    expect(user).to respond_to :endorsements_unlocked_since_last_visit
    expect(user).to respond_to :endorsements_since
    expect(user).to respond_to :endorsers
    expect(user).to respond_to :endorse
  end

end
