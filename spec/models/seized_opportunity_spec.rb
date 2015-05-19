require 'spec_helper'

RSpec.describe SeizedOpportunity, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:opportunity) }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:opportunity_id) }
end
