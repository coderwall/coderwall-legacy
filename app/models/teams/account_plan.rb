# == Schema Information
#
# Table name: teams_account_plans
#
#  plan_id    :integer
#  account_id :integer
#

class Teams::AccountPlan < ActiveRecord::Base
  belongs_to :plan
  belongs_to :account, :class_name => 'Teams::Account'
end
