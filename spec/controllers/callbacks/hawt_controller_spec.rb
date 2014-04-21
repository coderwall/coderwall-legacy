# encoding: utf-8

require 'services/protips/hawt_service'
describe Callbacks::HawtController do
  include AuthHelper
  before { http_authorize!(Rails.env, Rails.env) }

  let(:current_user) { Fabricate(:user, admin: true) }
  let(:protip) {
    Protip.create!(
      title: 'hello world',
      body: 'somethings that\'s meaningful and nice',
      topics: ['java', 'javascript'],
      user_id: current_user.id
    )
  }

  describe 'GET \'feature\'', pending: 'fixing the test auth' do
    it 'returns http success' do
      Services::Protips::HawtService.any_instance.should_receive(:feature!).with(protip.id, true)
      post 'feature', { protip_id: protip.id, hawt?: true, token: 'atoken' }
      ap response.status
      response.should be_success

    end
  end
end
