RSpec.describe RefreshTimelineJob do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(RefreshTimelineJob.get_sidekiq_options['queue']).
        to eql :timeline
    end
  end

end
