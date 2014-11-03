class AddSlugToProtips < ActiveRecord::Migration
  def change
    add_column :protips, :slug, :string
    add_index :protips, :slug
  end
end
