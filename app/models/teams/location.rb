class Teams::Location < ActiveRecord::Base
  include Geocoder::Model::ActiveRecord

  # Rails 3 is stupid
  belongs_to :team, class_name: 'Team',
    foreign_key: 'team_id',
    touch: true

  geocoded_by :address do |obj, results|
    if geo = results.first and obj.address.downcase.include?(geo.city.try(:downcase) || "")
      obj.city       = geo.city
      obj.state_code = geo.state_code
      obj.country    = geo.country
    end
  end

  after_validation :geocode, if: ->(team_location) { team_location.city.nil? }
end

# == Schema Information
# Schema version: 20140918031936
#
# Table name: teams_locations
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  address     :text
#  city        :string(255)
#  state_code  :string(255)
#  country     :string(255)
#  team_id     :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
