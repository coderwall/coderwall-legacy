RSpec.describe ExtractGithubProfile do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(ExtractGithubProfile.get_sidekiq_options["queue"]).to eql :github
    end
  end

end
