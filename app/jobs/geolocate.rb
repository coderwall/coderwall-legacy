class Geolocate
  extend ResqueSupport::Basic

  @queue = 'LOW'

  def perform
    User.active.not_geocoded.each do |user|
      user.geocode_location
      user.save!
    end
  end
end