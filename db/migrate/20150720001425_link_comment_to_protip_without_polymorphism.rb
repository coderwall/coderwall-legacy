class LinkCommentToProtipWithoutPolymorphism < ActiveRecord::Migration
  def up
    remove_column :comments, :commentable_type
    rename_column :comments, :commentable_id, :protip_id
    add_foreign_key :comments, :protips, name: "comments_protip_id_fk"
  end

  def down
  end
end
