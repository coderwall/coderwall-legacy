class AddNotNulltoProtipsSlug < ActiveRecord::Migration
  def up
    change_column_null :protips, :slug, false
  end

  def down
    change_column_null :protips, :slug, true
  end
end
