class TagAatoCleanup < ActiveRecord::Migration
  def up
   ActsAsTaggableOn::Tag.delete_all(taggings_count: 0)
   ActsAsTaggableOn::Tag.destroy_all(name: '')
   ActsAsTaggableOn::Tag.destroy_all(name: %w(navarro etagwerker mattvvhat Assembly angels  capital combinations turbulenz semerda))
   remove_index! 'tags', 'index_tags_on_name'
   add_index 'tags', ['name'], name: 'index_tags_on_name', unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
