class UnbansController < BaseAdminController

  # POST                  /users/:user_id/unbans(.:format)
  def create
    ban_params  = params.permit(:user_id)
    user        = User.find(ban_params[:user_id])
    return redirect_to(badge_url(username: user.username), notice: 'User is not banned.') unless user.banned?

    flash_notice = if UserBannerService.unban(user)
                     IndexUserProtipsService.run(user)
                     'Ban removed from user.'
                   else
                     'Ban could not be removed from user.'
                   end
    redirect_to(badge_url(username: user.username), notice: flash_notice)
  end
end
