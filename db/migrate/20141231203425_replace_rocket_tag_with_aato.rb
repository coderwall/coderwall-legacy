class ReplaceRocketTagWithAato < ActiveRecord::Migration
  def up
    # This was created by rocket_tag but not used anywhere.
    drop_table :alias_tags

    # This is something that AATO has that rocket_tag doesn't.
    add_column :tags, :taggings_count, :integer, default: 0

    # Populate the taggings_count properly
    ActsAsTaggableOn::Tag.reset_column_information
    ActsAsTaggableOn::Tag.find_each do |tag|
      ActsAsTaggableOn::Tag.reset_counters(tag.id, :taggings)
    end

    add_index 'tags', ['name'], name: 'index_tags_on_name', unique: true

    remove_index 'taggings', name: "index_taggings_on_tag_id"
    remove_index 'taggings', name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    add_index 'taggings',
      ['tag_id', 'taggable_id', 'taggable_type', 'context', 'tagger_id', 'tagger_type'], name: 'taggings_idx'
      
    #TODO, add unique constraint to taggings_idx
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
