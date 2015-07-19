require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { Fabricate(:user) }
  it 'should respond to instance methods' do
    expect(user).to respond_to :activate
    expect(user).to respond_to :activate!
    expect(user).to respond_to :unregistered?
    expect(user).to respond_to :not_active?
    expect(user).to respond_to :active?
    expect(user).to respond_to :pending?
    expect(user).to respond_to :banned?
    expect(user).to respond_to :complete_registration!
  end
end
