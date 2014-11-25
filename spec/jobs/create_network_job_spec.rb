RSpec.describe CreateNetworkJob do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(CreateNetworkJob.get_sidekiq_options["queue"]).to eql :network
    end
  end

end
