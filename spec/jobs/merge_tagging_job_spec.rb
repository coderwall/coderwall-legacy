RSpec.describe MergeTaggingJob do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(MergeTaggingJob.get_sidekiq_options["queue"]).to eql :data_cleanup
    end
  end

end
