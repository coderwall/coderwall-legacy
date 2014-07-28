class Teams::AccountPlan < ActiveRecord::Base
  belongs_to :plan
  belongs_to :account, :class_name => 'Teams::Account'
end

# == Schema Information
# Schema version: 20140728214411
#
# Table name: teams_account_plans
#
#  plan_id    :integer
#  account_id :integer
#
