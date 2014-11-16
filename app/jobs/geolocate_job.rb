class GeolocateJob
  include Sidekiq::Worker

  sidekiq_options queue: :user

  def perform
    User.active.not_geocoded.each do |user|
      user.geocode_location
      user.save!
    end
  end
end
