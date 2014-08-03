require 'spec_helper'
require 'vcr_helper'

RSpec.describe UserRefreshWorker, vcr: { cassette_name: 'UserRefreshWorker' }, sidekiq: :inline do
  let(:worker) { UserRefreshWorker.new }

  describe('#perform') do
    context 'when invalid user' do
      let(:user_id) { 1 }

      it { expect { worker.perform(user_id) }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'when valid user' do
      let(:user) { Fabricate(:user) }

      it 'should refresh user' do
        worker.perform(user.id)
        user.reload

        expect(user.last_refresh_at).not_to eq(nil)
      end
    end
  end
end
