require 'spec_helper'

RSpec.describe Comment, :type => :model do
  describe '#spam_report' do
    subject { super().spam_report }
    it { is_expected.to be_nil }
  end
end
