Fabricator(:plan) do
end

# == Schema Information
# Schema version: 20140713193201
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
