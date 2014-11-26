RSpec.describe ProtipMailerPopularProtipsSendWorker do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(ProtipMailerPopularProtipsSendWorker.get_sidekiq_options['queue']).
        to eql :mailer
    end
  end

end
