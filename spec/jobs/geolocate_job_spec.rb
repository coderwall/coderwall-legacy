RSpec.describe GeolocateJob do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(GeolocateJob.get_sidekiq_options["queue"]).to eql :user
    end
  end

end
