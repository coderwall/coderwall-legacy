# == Schema Information
#
# Table name: network_protips
#
#  id         :integer          not null, primary key
#  network_id :integer
#  protip_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe NetworkProtip, :type => :model do
  it { is_expected.to belong_to :network}
  it { is_expected.to belong_to :protip}
end
