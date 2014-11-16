require_dependency 'reverse_geocoder'

class ReverseGeolocateUserJob
  include Sidekiq::Worker
  include ReverseGeocoder

  sidekiq_options queue: :user

  def perform(username, ip_address)
    user = User.find_by_username(username)
    unless user.nil? or user.ip_lat
      geocoder = MaxMind.new
      begin
        address = geocoder.reverse_geocode(ip_address)
      rescue SystemExit
        address = nil
      end
      #puts "got > #{address}"
      unless address.nil?
        user.ip_lat = address[:latitude].to_f
        user.ip_lng = address[:longitude].to_f
        user.country = address[:country] if user.country.blank?
        user.city = address[:city] if user.city.blank?
        user.save(validate: false)
      end
    end
  end
end
