class UsersWithoutLocationCleanup < ActiveRecord::Migration
  def up
    User.delete_all(location: [nil,''])
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
