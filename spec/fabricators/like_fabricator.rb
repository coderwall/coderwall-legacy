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

Fabricator(:like) do
  value 1
end
