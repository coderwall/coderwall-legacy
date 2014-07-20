class CreateTeamsLocations < ActiveRecord::Migration
  def change
    create_table :teams_locations do |t|
      t.string :name
      t.string :description
      t.string :address
      t.string :city, default: nil
      t.string :state_code, default: nil
      t.string :country, default: nil
      t.integer :team_id, null: false
      t.timestamps
    end
    # field :points_of_interest, type: Array, default: []
    # field :coordinates, type: Array
  end
end
