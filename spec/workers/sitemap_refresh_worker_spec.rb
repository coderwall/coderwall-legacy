RSpec.describe SitemapRefreshWorker do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(SitemapRefreshWorker.get_sidekiq_options["queue"]).to eql :index
    end
  end

end
