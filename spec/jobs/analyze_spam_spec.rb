describe AnalyzeSpam do
  let(:spammable){ Fabricate(:comment) }
  before { @analyzer = AnalyzeSpam.new(spammable) }

  describe "#perform" do
    context "when it's a spam" do
      before { spammable.stub(:spam?).and_return true }

      it "should create a spam report" do
        @analyzer.perform
        spammable.spam_report.should_not be_nil
      end
    end

    context "when it's not a spam" do
      before { spammable.stub(:spam?).and_return false }

      it "should not create a spam report" do
        @analyzer.perform
        spammable.spam_report.should be_nil
      end
    end
  end
end
