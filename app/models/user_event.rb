class UserEvent < ActiveRecord::Base
  belongs_to :user
  serialize :data, Hash
end

# == Schema Information
# Schema version: 20140918031936
#
# Table name: user_events
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  name       :string(255)
#  data       :text
#  created_at :datetime         default(2012-03-12 21:01:10 UTC)
#
