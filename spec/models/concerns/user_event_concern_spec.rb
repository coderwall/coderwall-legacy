require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {Fabricate(:user)}
  it 'should respond to instance methods' do
    expect(user).to respond_to :subscribed_channels
    expect(user).to respond_to :generate_event
    expect(user).to respond_to :event_audience
    expect(user).to respond_to :to_event_hash
    expect(user).to respond_to :event_type
  end

end
