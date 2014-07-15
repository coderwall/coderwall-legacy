class UserEvent < ActiveRecord::Base
  belongs_to :user
  serialize :data, Hash
end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: user_events
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  name       :string(255)
#  data       :text
#  created_at :datetime         default(2014-02-20 22:39:11 UTC)
#
