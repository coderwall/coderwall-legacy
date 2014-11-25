RSpec.describe ClearExpiredSessionsJob do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(ClearExpiredSessionsJob.get_sidekiq_options["queue"]).
        to eql :data_cleanup
    end
  end

end
