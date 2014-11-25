require 'sidekiq/testing'

RSpec.describe AnalyzeSpamJob do

  describe 'queueing' do
    it 'pushes jobs to the correct queue' do
      expect(AnalyzeSpamJob.get_sidekiq_options["queue"]).to eql :data_cleanup
    end
  end

# TODO FIXME
#  describe '#perform' do
#    context 'when it is a spam' do
#      it 'should create a spam report' do
#        allow_any_instance_of(Comment).to receive(:spam?).and_return(true)
#        spammable = Fabricate(:comment)
#        AnalyzeSpamJob.perform_async(id: spammable.id, klass: spammable.class.name)
#        expect(spammable.spam_report).not_to be_nil
#      end
#    end

#    context 'when it is not a spam' do
#      it 'should not create a spam report' do
#        allow_any_instance_of(Comment).to receive(:spam?).and_return(false)
#        spammable = Fabricate(:comment)
#        AnalyzeSpamJob.perform_async(id: spammable.id, klass: spammable.class.name)
#        expect(spammable.spam_report).to be_nil
#      end
#    end
#  end
end
