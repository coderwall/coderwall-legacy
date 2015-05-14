# encoding: utf-8

RSpec.describe Callbacks::HawtController, type: :controller do
  include AuthHelper
  before { http_authorize!(Rails.env, Rails.env) }

  let(:current_user) { Fabricate(:user, admin: true) }
  let(:protip) do
    Protip.create!(
      title: 'hello world',
      body: 'somethings that\'s meaningful and nice',
      topics: %w(java javascript),
      user_id: current_user.id
    )
  end

  describe 'GET \'feature\'', pending: 'fixing the test auth' do
    it 'returns http success' do
      expect_any_instance_of(Protips::HawtService).to receive(:feature!).with(protip.id, true)
      post 'feature',  protip_id: protip.id, hawt?: true, token: 'atoken'
      expect(response).to be_success

    end
  end
end
