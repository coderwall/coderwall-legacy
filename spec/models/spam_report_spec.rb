require 'spec_helper'

RSpec.describe SpamReport, :type => :model do
  describe '#spammable' do
    subject { super().spammable }
    it { is_expected.to be_nil }
  end
end

# == Schema Information
# Schema version: 20140728214411
#
# Table name: spam_reports
#
#  id             :integer          not null, primary key
#  spammable_id   :integer          not null
#  spammable_type :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
