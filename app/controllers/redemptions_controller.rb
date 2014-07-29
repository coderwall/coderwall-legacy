class RedemptionsController < ApplicationController
  def show
    if @redemption = Redemption.for_code(params[:code])
      if signed_in?
        @redemption.award!(current_user)
        if current_user.pending?
          current_user.activate
          NotifierMailer.welcome_email(current_user.username).deliver
          RefreshUserJob.perform_async(current_user.username)
        end
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
