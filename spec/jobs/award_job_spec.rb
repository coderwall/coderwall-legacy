RSpec.describe AwardJob do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(AwardJob.get_sidekiq_options["queue"]).to eql :user
    end
  end

end
