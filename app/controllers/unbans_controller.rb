class UnbansController < BaseAdminController
  def create
    ban_params  = params.permit(:user_id)
    user        = User.find(ban_params[:user_id])
    return redirect_to(badge_url(username: user.username), notice: 'User is not banned.') unless user.banned?

    flash_notice = if Services::Banning::UserBanner.unban(user)
                     Services::Banning::IndexUserProtips.run(user)
                     'Ban removed from user.'
                   else
                     'Ban could not be removed from user.'
                   end
    redirect_to(badge_url(username: user.username), notice: flash_notice)
  end
end
