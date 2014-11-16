RSpec.describe ProcessProtipJob do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(ProcessProtipJob.get_sidekiq_options["queue"]).to eql :protip
    end
  end

end
