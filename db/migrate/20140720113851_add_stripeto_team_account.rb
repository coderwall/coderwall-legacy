class AddStripetoTeamAccount < ActiveRecord::Migration
  def up
    add_column :teams_accounts, :stripe_card_token, :string, null: false
    add_column :teams_accounts, :stripe_customer_token, :string, null: false
    add_column :teams_accounts, :admin_id, :integer, null: false
    add_column :teams_accounts, :trial_end, :datetime, default: nil
    change_column :teams_accounts, :team_id, :integer, null: false, unique: true
  end

end
