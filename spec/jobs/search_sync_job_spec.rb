RSpec.describe SearchSyncJob do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(SearchSyncJob.get_sidekiq_options['queue']).to eql :search_sync
    end
  end

end
