class Teams::AccountPlan < ActiveRecord::Base
  belongs_to :plan
  belongs_to :account, :class_name => 'Teams::Account'
end
