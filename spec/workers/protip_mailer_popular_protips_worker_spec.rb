RSpec.describe ProtipMailerPopularProtipsWorker do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(ProtipMailerPopularProtipsWorker.get_sidekiq_options["queue"]).
        to eql :mailer
    end
  end

end
