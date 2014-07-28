require 'rails_helper'

RSpec.describe Teams::Member, :type => :model do
  it {is_expected.to belong_to(:team).counter_cache(:team_size)}
  it {is_expected.to belong_to(:user)}
end

# == Schema Information
# Schema version: 20140728205954
#
# Table name: teams_members
#
#  id            :integer          not null, primary key
#  team_id       :integer          not null
#  user_id       :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  team_size     :integer          default(0)
#  badges_count  :integer
#  email         :string(255)
#  inviter_id    :integer
#  name          :string(255)
#  thumbnail_url :string(255)
#  username      :string(255)
#
