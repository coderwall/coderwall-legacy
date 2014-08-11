module OpportunitiesHelper

  def add_job_to_jobboard_path(team, options={})
    team.nil? ? employers_path : new_team_opportunity_path(team, options)
  end

  def add_job_or_signin_path
    signed_in? ? add_job_to_jobboard_path(current_user.team, tags: params[:skill]) : signin_path
  end

  def job_location_string(location)
    location == "Worldwide" ? location : "in #{location}"
  end

  def google_maps_image_url(location)
    zoom = 11
    zoom = 1 if location.downcase == "worldwide"
    "https://maps.googleapis.com/maps/api/staticmap?center=#{CGI.escape(location)}&size=2048x100&scale=2&zoom=#{zoom}&format=png32&sensor=false"
  end

  def nokia_maps_image_url(lat, lng)
    zoom = 10
    zoom = 2 if lat == lng and lat == 0.0
    "http://m.nok.it/?app_id=ygXYjbsLrDEvbjkwVQfJ&app_code=Ydp0c07X_uV5qldH61s5Bg&c=#{lat},#{lng}&w=1023&z=#{zoom}&nord&nodot"
  end

  def location_photo_path(location)
    photo = LocationPhoto::Panoramic.for(location)
    asset_path("locations/panoramic/#{photo.image_name}")
  end
end
