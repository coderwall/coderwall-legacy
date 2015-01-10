class RestorePremiumTeamAdmins < ActiveRecord::Migration
  def up
    premium_admins = Teams::Account.pluck(:admin_id)
    Teams::Member.where(user_id: premium_admins).update_all(role: 'admin')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
