require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {Fabricate(:user)}
  it 'should respond to instance methods' do
    expect(user).to respond_to :api_key
    expect(user).to respond_to :generate_api_key!
  end
end
