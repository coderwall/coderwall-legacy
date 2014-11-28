require 'spec_helper'

RSpec.describe SpamReport, type: :model do
  describe '#spammable' do
    subject { super().spammable }
    it { is_expected.to be_nil }
  end
end
