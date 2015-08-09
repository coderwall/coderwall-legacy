class AddTitleToMembership < ActiveRecord::Migration
  def change
    add_column :teams_members, :title, :string
  end
end
