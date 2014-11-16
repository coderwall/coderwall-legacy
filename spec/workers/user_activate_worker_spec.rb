require 'vcr_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

RSpec.describe UserActivateWorker do
  let(:worker) { UserActivateWorker.new }

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(UserActivateWorker.get_sidekiq_options["queue"]).to eql :user
    end
  end

  describe('#perform') do
    context 'when invalid user' do
      let(:user_id) { 1 }

      it { expect { worker.perform(user_id) }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'when pending user' do
      let(:user) { Fabricate(:pending_user) }

      it 'should activate user' do
        worker.perform(user.id)
        user.reload

        expect(user.active?).to eq(true)
        expect(user.activated_on).not_to eq(nil)
      end

      it "should send welcome mail" do
        mail = double("mail")
        expect(NotifierMailer).to receive(:welcome_email).with(user.username).and_return(mail)
        expect(mail).to receive(:deliver)
        worker.perform(user.id)
      end

      it "should create refresh job" do
        expect_any_instance_of(RefreshUserJob).to receive(:perform).with(user.id)
        worker.perform(user.id)
      end

    end

    context 'when activate user' do
      let(:user) { Fabricate(:user) }

      it 'should do nothing' do
        worker.perform(user.id)
        user.reload

        expect(user.updated_at).to eq(user.created_at)
      end
    end
  end
end
