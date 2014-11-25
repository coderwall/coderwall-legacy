RSpec.describe GenerateEventJob do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(GenerateEventJob.get_sidekiq_options["queue"]).
        to eql :event_publisher
    end
  end

end
