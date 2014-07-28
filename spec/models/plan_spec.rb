require 'spec_helper'

RSpec.describe Plan, :type => :model do
  it {is_expected.to have_many(:subscriptions)}
  it {is_expected.to validate_presence_of(:amount)}
  it {is_expected.to validate_presence_of(:name)}
  it {is_expected.to validate_presence_of(:currency)}
end

# == Schema Information
# Schema version: 20140728214411
#
# Table name: plans
#
#  id                  :integer          not null, primary key
#  amount              :integer
#  interval            :string(255)      default("month")
#  name                :string(255)
#  currency            :string(255)      default("usd")
#  public_id           :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  analytics           :boolean          default(FALSE)
#  interval_in_seconds :integer          default(2592000)
#
