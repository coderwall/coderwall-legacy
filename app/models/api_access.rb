# == Schema Information
#
# Table name: api_accesses
#
#  id         :integer          not null, primary key
#  api_key    :string(255)
#  awards     :text
#  created_at :datetime
#  updated_at :datetime
#

class ApiAccess < ActiveRecord::Base
  #TODO change column to postgresql array
  serialize :awards, Array

  def can_award?(badge_name)
    awards.include? badge_name
  end
end
