# == Schema Information
#
# Table name: teams_links
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  url        :text
#  team_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Teams::Link, type: :model do
  it { is_expected.to belong_to(:team) }
end
