class FollowsController < ApplicationController
  before_action :access_required
  cache_sweeper :follow_sweeper

  helper_method :is_viewing_followers?

  def index
    @user = User.find_by_username(params[:username])
    return redirect_to(user_follows_url(username: current_user.username)) unless @user == current_user || current_user.admin?
    @network = case params[:type]
                 when :followers
                   @user.followers_by_type(User.name)
                 else
                   @user.following_by_type(User.name)
               end
    @network = @network.order('score_cache DESC').page(params[:page]).per(50)
  end

  def create
    apply_cache_buster

    if params[:type] == :user
      @user = User.find_by_username(params[:username])
      if current_user.following?(@user)
        current_user.stop_following(@user)
      else
        current_user.follow(@user)
      end
      respond_to do |format|
        format.json { render json: { dom_id: dom_id(@user), following: current_user.following?(@user) }.to_json }
        format.js { render json: { dom_id: dom_id(@user), following: current_user.following?(@user) }.to_json }
      end
    end
  end

  private
  def is_viewing_followers?
    params[:type] == :followers
  end
end