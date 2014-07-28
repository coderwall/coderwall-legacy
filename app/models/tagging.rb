class Tagging < ActiveRecord::Base
  belongs_to :tag
end

# == Schema Information
# Schema version: 20140728205954
#
# Table name: taggings
#
#  id            :integer          not null, primary key
#  tag_id        :integer
#  taggable_id   :integer
#  taggable_type :string(255)
#  tagger_id     :integer
#  tagger_type   :string(255)
#  context       :string(255)
#  created_at    :datetime
#
