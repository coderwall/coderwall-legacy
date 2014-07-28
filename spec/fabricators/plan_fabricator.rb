Fabricator(:plan) do
end

# == Schema Information
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
