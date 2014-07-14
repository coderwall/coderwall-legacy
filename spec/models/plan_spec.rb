# == Schema Information
#
# Table name: plans
#
#  id         :integer          not null, primary key
#  amount     :integer
#  interval   :string(255)
#  name       :string(255)
#  currency   :string(255)
#  public_id  :string(255)
#  created_at :datetime
#  updated_at :datetime
#  analytics  :boolean          default(FALSE)
#

require 'spec_helper'

RSpec.describe Plan, :type => :model do
  skip "add some examples to (or delete) #{__FILE__}"
end
