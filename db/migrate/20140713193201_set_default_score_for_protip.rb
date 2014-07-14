class SetDefaultScoreForProtip < ActiveRecord::Migration
  def change
    change_column :protips, :upvotes_value_cache, :integer, default: 0, null: false
  end
end
