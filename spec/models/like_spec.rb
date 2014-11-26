require 'spec_helper'

RSpec.describe Like, type: :model do
  skip "add some examples to (or delete) #{__FILE__}"
end

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
