class ConvertSkillsColumnsToDatabaseJson < ActiveRecord::Migration
  def up
    add_column :skills, :links, :json, default: '{}'
  end
end
