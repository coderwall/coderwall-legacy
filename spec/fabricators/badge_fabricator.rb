Fabricator(:badge) do
  badge_class_name { sequence(:badge_name) { |_i| 'Octopussy' } }
end

# == Schema Information
#
# Table name: badges
#
#  id               :integer          not null, primary key
#  created_at       :datetime
#  updated_at       :datetime
#  user_id          :integer
#  badge_class_name :string(255)
#
