# == Schema Information
#
# Table name: teams_accounts
#
#  id         :integer          not null, primary key
#  team_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Teams::Account, :type => :model do
  it {is_expected.to belong_to(:team)}
end
