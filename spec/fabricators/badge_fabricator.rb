Fabricator(:badge) do
  badge_class_name { sequence(:badge_name) { |i| "Octopussy" } }
end

# == Schema Information
# Schema version: 20140728214411
#
# Table name: badges
#
#  id               :integer          not null, primary key
#  created_at       :datetime
#  updated_at       :datetime
#  user_id          :integer
#  badge_class_name :string(255)
#
