class DropAdminFromTeamAccount < ActiveRecord::Migration
  def up
    remove_column :teams_accounts, :admin_id
    remove_column :teams_accounts, :trial_end
    add_column :teams_account_plans, :id, :primary_key
    add_column :teams_account_plans, :state, :string, default: :active
    add_column :teams_account_plans, :expire_at, :datetime
  end
end
