require 'rails_helper'

RSpec.describe Protip, type: :model do
  let(:protip) {Fabricate(:protip)}
  it 'should respond to ownership instance methods' do
    expect(protip).to respond_to :owned_by?
    expect(protip).to respond_to :owner?
  end
end
