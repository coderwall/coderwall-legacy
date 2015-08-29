class PicturesController < ApplicationController

  # POST                  /users/:user_id/pictures(.:format)
  def create
    picture = current_user.create_picture(file: params[:picture])
    render json: picture
  end
end