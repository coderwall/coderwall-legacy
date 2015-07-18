# == Schema Information
#
# Table name: teams_account_plans
#
#  plan_id    :integer
#  account_id :integer
#  id         :integer          not null, primary key
#  state      :string(255)      default("active")
#  expire_at  :datetime
#

class Teams::AccountPlan < ActiveRecord::Base
  belongs_to :plan
  belongs_to :account, :class_name => 'Teams::Account'
end
