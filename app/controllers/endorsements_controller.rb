class EndorsementsController < ApplicationController

  def index
    flash[:notice] = 'You must be signed in to make an endorsement.'
    #This is called when someone tries to endorse while unauthenticated
    return_to_user = badge_url(username: User.find(params[:user_id]).username)
    store_location!(return_to_user)
    redirect_to(signin_path)
  end

  def create
    return head(:forbidden) unless signed_in? && params[:user_id] != current_user.id.to_s
    @user  = User.find(params[:user_id])
    @skill = @user.skills.find(params[:skill_id])
    @skill.endorsed_by(current_user) unless @skill.endorsed_by?(current_user)
    @skill.reload
    record_event('endorsed user', speciality: @skill.name)
    render json: {
                   unlocked: !@skill.locked?,
                   message:  "Awesome! #{@skill.endorse_message}"
                 }.to_json
  end

  def show #Used by api.coderwall.com
    @user = User.find_by_username(params[:username])
    return head(:not_found) if @user.nil?
    render json: {
      endorsements:  @user.endorsements_count,
      last_modified: @user.updated_at.utc
    }
  end
end