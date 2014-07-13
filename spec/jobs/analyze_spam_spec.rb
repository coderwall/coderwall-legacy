describe AnalyzeSpam do
  describe '#perform' do
    context 'when it is a spam' do
      it 'should create a spam report' do
        Comment.any_instance.stub(:spam?).and_return(true)
        spammable = Fabricate(:comment)
        AnalyzeSpam.new(id: spammable.id, klass: spammable.class.name).perform
        spammable.spam_report.should_not be_nil
      end
    end

    context 'when it is not a spam' do
      it 'should not create a spam report' do
        Comment.any_instance.stub(:spam?).and_return(false)
        spammable = Fabricate(:comment)
        AnalyzeSpam.new(id: spammable.id, klass: spammable.class.name).perform
        spammable.spam_report.should be_nil
      end
    end
  end
end
