class FollowsController < ApplicationController
  before_filter :access_required
  cache_sweeper :follow_sweeper

  helper_method :is_viewing_followers?

  def index
    @user = User.with_username(params[:username])
    return redirect_to(user_follows_url(username: current_user.username)) unless @user == current_user || current_user.admin?
    @network = @user.followers_by_type(User.name) if is_viewing_followers?
    @network = @user.following_by_type(User.name) if is_viewing_following?
    @network = @network.order('score_cache DESC').page(params[:page]).per(50)
  end

  def create
    apply_cache_buster

    if params[:type] == :user
      @user = User.with_username(params[:username])
      if current_user.following?(@user)
        current_user.stop_following(@user)
      else
        current_user.follow(@user)
      end
      respond_to do |format|
        format.json { render json: { dom_id: dom_id(@user), following: current_user.following?(@user) }.to_json }
        format.js { render json: { dom_id: dom_id(@user), following: current_user.following?(@user) }.to_json }
      end
    else
      # TODO: Refactor teams to use acts_as_follower after we move Team out of mongodb
      if params[:id] =~ /^[0-9A-F]{24}$/i
        @team = Team.find(params[:id])
      else
        @team = Team.where(slug: params[:id]).first
      end
      if current_user.following_team?(@team)
        current_user.unfollow_team!(@team)
      else
        current_user.follow_team!(@team)
      end
      respond_to do |format|
        format.json { render json: { dom_id: dom_id(@team), following: current_user.following_team?(@team) }.to_json }
        format.js { render json: { dom_id: dom_id(@team), following: current_user.following_team?(@team) }.to_json }
      end
    end
  end

  private
  def is_viewing_followers?
    params[:type] == :followers
  end

  def is_viewing_following?
    params[:type] == :following
  end
end
