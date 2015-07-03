class PicturesController < ApplicationController
  def create
    picture = current_user.create_picture(file: params[:picture])
    render json: picture
  end
end