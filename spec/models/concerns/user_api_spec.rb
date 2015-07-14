require 'rails_helper'

RSpec.describe User, type: :model do

  let(:user) {Fabricate(:user)}
  it 'should respond to instance methods' do
    expect(user).to respond_to :api_key
    expect(user).to respond_to :generate_api_key!
  end

  describe 'api key' do
    let(:user) { Fabricate(:user) }

    it 'should assign and save an api_key if not exists' do
      api_key = user.api_key
      expect(api_key).not_to be_nil
      expect(api_key).to eq(user.api_key)
      user.reload
      expect(user.api_key).to eq(api_key)
    end

    it 'should assign a new api_key if the one generated already exists' do
      RandomSecure = double('RandomSecure')
      allow(RandomSecure).to receive(:hex).and_return('0b5c141c21c15b34')
      user2 = Fabricate(:user)
      api_key2 = user2.api_key
      user2.api_key = RandomSecure.hex(8)
      expect(user2.api_key).not_to eq(api_key2)
      api_key1 = user.api_key
      expect(api_key1).not_to eq(api_key2)
    end
  end


end
