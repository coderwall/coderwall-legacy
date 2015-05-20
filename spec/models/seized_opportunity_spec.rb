# == Schema Information
#
# Table name: seized_opportunities
#
#  id             :integer          not null, primary key
#  opportunity_id :integer
#  user_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#

require 'spec_helper'

RSpec.describe SeizedOpportunity, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:opportunity) }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:opportunity_id) }
end
