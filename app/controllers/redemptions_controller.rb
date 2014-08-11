class RedemptionsController < ApplicationController
  def show
    if @redemption = Redemption.for_code(params[:code])
      if signed_in?
        @redemption.award!(current_user)
        current_user.activate if current_user.pending?
        redirect_to(destination_url)
      else
        store_location!
      end
    else
      flash[:notice] = "#{params[:code]} is an invalid code."
      redirect_to root_url
    end
  end
end
