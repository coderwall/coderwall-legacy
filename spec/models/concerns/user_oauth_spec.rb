require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {Fabricate(:user)}
  it 'should respond to instance methods' do
    expect(user).to respond_to :apply_oauth
    expect(user).to respond_to :extract_joined_on
    expect(user).to respond_to :extract_from_oauth_extras
  end

end
