class FixTypesOnPgTeams < ActiveRecord::Migration
  def change
    change_column(:teams, :mean, :float, default: 0.0)
    change_column(:teams, :median, :float, default: 0.0)
    change_column(:teams, :score, :float, default: 0.0)
    change_column(:teams, :total, :float, default: 0.0)
  end
end
