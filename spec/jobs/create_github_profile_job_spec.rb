RSpec.describe CreateGithubProfileJob do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(CreateGithubProfileJob.get_sidekiq_options["queue"]).to eql :github
    end
  end

end
