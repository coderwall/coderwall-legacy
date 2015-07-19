require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { Fabricate(:user) }
  it 'should respond to instance methods' do
    expect(user).to respond_to :apply_to
    expect(user).to respond_to :already_applied_for?
    expect(user).to respond_to :has_resume?
  end
end
