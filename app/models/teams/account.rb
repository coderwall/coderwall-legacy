class Teams::Account < ActiveRecord::Base
  belongs_to :team, class_name: 'PgTeam', foreign_key: 'team_id'
  validates :team_id, presence: true,
                      uniqueness: true
  validates_presence_of :stripe_card_token
  validates_presence_of :stripe_customer_token
end

# == Schema Information
#
# Table name: teams_accounts
#
#  id                    :integer          not null, primary key
#  team_id               :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  stripe_card_token     :string(255)      not null
#  stripe_customer_token :string(255)      not null
#  admin_id              :integer          not null
#  trial_end             :datetime
#
