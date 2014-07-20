# == Schema Information
#
# Table name: teams_accounts
#
#  id                    :integer          not null, primary key
#  team_id               :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  stripe_card_token     :string(255)      not null
#  stripe_customer_token :string(255)      not null
#  admin_id              :integer          not null
#  trial_end             :datetime
#

require 'rails_helper'

RSpec.describe Teams::Account, :type => :model do
  it { is_expected.to belong_to(:team) }
  it { is_expected.to validate_presence_of(:team_id) }
  it { is_expected.to validate_presence_of(:stripe_card_token) }
  it { is_expected.to validate_presence_of(:stripe_customer_token) }
  # it { is_expected.to validate_uniqueness_of(:team_id) }
end
