Fabricator(:badge) do
  badge_class_name { sequence(:badge_name) { |_i| 'Octopussy' } }
end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: badges
#
#  id               :integer          not null, primary key
#  created_at       :datetime
#  updated_at       :datetime
#  user_id          :integer          indexed, indexed => [badge_class_name]
#  badge_class_name :string(255)      indexed => [user_id]
#
# Indexes
#
#  index_badges_on_user_id                       (user_id)
#  index_badges_on_user_id_and_badge_class_name  (user_id,badge_class_name) UNIQUE
#
