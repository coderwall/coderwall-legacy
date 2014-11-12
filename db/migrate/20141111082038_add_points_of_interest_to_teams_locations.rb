class AddPointsOfInterestToTeamsLocations < ActiveRecord::Migration
  def change
    add_column :teams_locations, :points_of_interest, :string, array: true, default: []
  end
end
