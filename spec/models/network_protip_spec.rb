require 'rails_helper'

RSpec.describe NetworkProtip, :type => :model do
  it { is_expected.to belong_to :network}
  it { is_expected.to belong_to :protip}
end
