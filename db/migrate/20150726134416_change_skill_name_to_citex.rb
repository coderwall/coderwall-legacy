class ChangeSkillNameToCitex < ActiveRecord::Migration
  def up
    change_column :skills, :name, :citext
  end
end
