RSpec.describe AssignNetworksJob do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(AssignNetworksJob.get_sidekiq_options['queue']).to eql :network
    end
  end

end
