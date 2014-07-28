require 'rails_helper'

RSpec.describe Teams::Link, :type => :model do
  it {is_expected.to belong_to(:team)}
end

# == Schema Information
# Schema version: 20140728205954
#
# Table name: teams_links
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  url        :string(255)
#  team_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
