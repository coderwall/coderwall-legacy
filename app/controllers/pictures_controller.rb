class PicturesController < ApplicationController
  def create
    @picture = Picture.create!(file: params[:picture], user: current_user)
    return render json: @picture.to_json
  end
end