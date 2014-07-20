class Teams::Account < ActiveRecord::Base
  belongs_to :team, class_name: 'PgTeam', foreign_key: 'team_id'
  has_many :account_plans, :class_name => 'Teams::AccountPlan'
  has_many :plans, through: :account_plans
  belongs_to :admin, class_name: 'User'

  validates :team_id, presence: true,
                      uniqueness: true
  validates_presence_of :stripe_card_token
  validates_presence_of :stripe_customer_token 
end

