class FixTypesOnPgTeams < ActiveRecord::Migration
  def change
    change_column(:teams, :mean,   :decimal,  precision: 40, scale: 30, default: 0.0)
    change_column(:teams, :median, :decimal,  precision: 40, scale: 30, default: 0.0)
    change_column(:teams, :score,  :decimal,  precision: 40, scale: 30, default: 0.0)
    change_column(:teams, :total,  :decimal,  precision: 40, scale: 30, default: 0.0)
  end
end
