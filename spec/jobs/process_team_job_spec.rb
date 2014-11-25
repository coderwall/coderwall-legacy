RSpec.describe ProcessTeamJob do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(ProcessTeamJob.get_sidekiq_options["queue"]).to eql :team
    end
  end

end
