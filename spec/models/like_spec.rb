require 'spec_helper'

RSpec.describe Like, :type => :model do
  skip "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: likes
#
#  id            :integer          not null, primary key
#  value         :integer
#  tracking_code :string(255)
#  user_id       :integer          indexed => [likable_id, likable_type]
#  likable_id    :integer          indexed => [likable_type, user_id]
#  likable_type  :string(255)      indexed => [likable_id, user_id]
#  created_at    :datetime
#  updated_at    :datetime
#  ip_address    :string(255)
#
# Indexes
#
#  index_likes_on_user_id  (likable_id,likable_type,user_id) UNIQUE
#
