require 'vcr_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

RSpec.describe ActivateUserWorker do
  let(:worker) { ActivateUserWorker.new }

  describe('#perform') do
    context 'when invalid user' do
      let(:user_id) { 1 }

      it { expect { worker.perform(user_id) }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'when pending user' do
      let(:user_id) { Fabricate(:pending_user).id }

      context 'when always_activate' do
        it
      end
      context 'when not always_activate' do
        it
      end
    end

    context 'when activate user' do
      let(:user_id) { Fabricate(:user).id }

      context 'when always_activate' do
        it
      end
      context 'when not always_activate' do
        it
      end
    end
  end
end
