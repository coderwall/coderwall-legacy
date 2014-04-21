class LegacyController < ApplicationController
  def show
    #this is to support legacy implementations of the api
    #it will redirect old image requests to the CDN
    head :moved_permanently, location: view_context.asset_path("#{params[:filename]}.#{params[:extension]}")
  end
end