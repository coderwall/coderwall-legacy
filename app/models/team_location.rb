# Postgresed  [WIP] : Teams::Location
class TeamLocation
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  embedded_in :team

  field :name
  field :description
  field :points_of_interest, type: Array, default: []
  field :address
  field :city, default: nil
  field :state_code, default: nil
  field :country, default: nil
  field :coordinates, type: Array

  geocoded_by :address do |obj, results|
    if geo = results.first and obj.address.downcase.include?(geo.city.try(:downcase) || "")
      obj.city       = geo.city
      obj.state_code = geo.state_code
      obj.country    = geo.country
    end
  end

  after_validation :geocode, if: lambda { |team_location| team_location.city.nil? }
end