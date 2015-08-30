class BansController < BaseAdminController

  # POST                  /users/:user_id/bans(.:format)
  def create
    ban_params = params.permit(:user_id)
    user = User.find(ban_params[:user_id])
    return redirect_to(badge_url(username: user.username), notice: 'User is already banned.') if user.banned?

    flash_notice = if UserBannerService.ban(user)
                     'User successfully banned.'
                   else
                     'User could not be banned.'
                   end
    redirect_to(badge_url(username: user.username), notice: flash_notice)
  end
end
