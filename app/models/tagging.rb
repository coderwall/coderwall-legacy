class Tagging < ActiveRecord::Base
  belongs_to :tag
end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: taggings
#
#  id            :integer          not null, primary key
#  tag_id        :integer          indexed
#  taggable_id   :integer          indexed => [taggable_type, context]
#  taggable_type :string(255)      indexed => [taggable_id, context]
#  tagger_id     :integer
#  tagger_type   :string(255)
#  context       :string(255)      indexed => [taggable_id, taggable_type]
#  created_at    :datetime
#
# Indexes
#
#  index_taggings_on_tag_id                                     (tag_id)
#  index_taggings_on_taggable_id_and_taggable_type_and_context  (taggable_id,taggable_type,context)
#
