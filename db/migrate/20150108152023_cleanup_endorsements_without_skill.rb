class CleanupEndorsementsWithoutSkill < ActiveRecord::Migration
  def up
    Endorsement.delete_all(skill_id: [nil,''])
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
