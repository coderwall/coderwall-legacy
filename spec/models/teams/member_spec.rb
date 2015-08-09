# == Schema Information
#
# Table name: teams_members
#
#  id          :integer          not null, primary key
#  team_id     :integer          not null
#  user_id     :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  state       :string(255)      default("pending")
#  score_cache :float
#  team_banner :string(255)
#  team_avatar :string(255)
#  role        :string(255)      default("member")
#  title       :string(255)
#

require 'rails_helper'

RSpec.describe Teams::Member, type: :model do
  it { is_expected.to belong_to(:team).counter_cache(:team_size) }
  it { is_expected.to belong_to(:user) }
end
