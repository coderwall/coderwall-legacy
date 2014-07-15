class ApiAccess < ActiveRecord::Base
  serialize :awards, Array

  class << self
    def for(api_key)
      where(api_key: api_key).first
    end
  end

  def can_award?(badge_name)
    awards.include? badge_name
  end
end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: api_accesses
#
#  id         :integer          not null, primary key
#  api_key    :string(255)
#  awards     :text
#  created_at :datetime
#  updated_at :datetime
#
