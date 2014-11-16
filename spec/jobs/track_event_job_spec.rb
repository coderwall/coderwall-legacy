RSpec.describe TrackEventJob do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(TrackEventJob.get_sidekiq_options["queue"]).to eql :event_tracker
    end
  end

end
