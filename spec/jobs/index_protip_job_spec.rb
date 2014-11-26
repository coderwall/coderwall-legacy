RSpec.describe IndexProtipJob do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(IndexProtipJob.get_sidekiq_options['queue']).to eql :index
    end
  end

end
