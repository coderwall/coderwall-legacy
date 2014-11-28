RSpec.describe ActivatePendingUsersWorker do
  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(ActivatePendingUsersWorker.get_sidekiq_options['queue']).
        to eql :user
    end
  end
end
