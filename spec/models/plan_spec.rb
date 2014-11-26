require 'spec_helper'

RSpec.describe Plan, type: :model do
  it { is_expected.to have_many(:subscriptions) }
  it { is_expected.to validate_presence_of(:amount) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:currency) }
end
