RSpec.describe ProtipIndexerWorker do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(ProtipIndexerWorker.get_sidekiq_options["queue"]).to eql :index
    end
  end

end
