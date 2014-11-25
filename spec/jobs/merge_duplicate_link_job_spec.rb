RSpec.describe MergeDuplicateLinkJob do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(MergeDuplicateLinkJob.get_sidekiq_options["queue"]).
        to eql :data_cleanup
    end
  end

end
