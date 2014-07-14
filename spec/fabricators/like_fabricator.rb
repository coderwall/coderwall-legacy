# == Schema Information
#
# Table name: likes
#
#  id            :integer          not null, primary key
#  value         :integer
#  tracking_code :string(255)
#  user_id       :integer
#  likable_id    :integer
#  likable_type  :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  ip_address    :string(255)
#
# Indexes
#
#  index_likes_on_user_id  (likable_id,likable_type,user_id) UNIQUE
#

Fabricator(:like) do
  value 1
end
