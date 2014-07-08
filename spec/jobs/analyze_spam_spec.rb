describe AnalyzeSpam do
  describe '#perform' do
    context 'when it is a spam' do
      it 'should create a spam report' do
        Protip.any_instance.stub(:index_search)
        spammable = Fabricate(:comment)
        spammable.stub(:spam?).and_return(true)
        AnalyzeSpam.new(spammable).perform
        spammable.spam_report.should_not be_nil
      end
    end

    context 'when it is not a spam' do

      it 'should not create a spam report' do
        Protip.any_instance.stub(:index_search)
        spammable = Fabricate(:comment)
        spammable.stub(:spam?).and_return(false)
        spammable.spam_report.should be_nil
      end
    end
  end
end
