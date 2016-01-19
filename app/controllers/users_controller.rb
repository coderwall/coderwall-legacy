class UsersController < ApplicationController
  after_action :track_referrer, only: :show
  skip_before_action :require_registration, only: [:edit, :update]

  layout 'coderwallv2', only: :edit

  # GET                   /users/new(.:format)
  def new
    return redirect_to(destination_url) if signed_in?
    return redirect_to(new_session_url) if oauth.blank?

    @user = User.for_omniauth(oauth)
  end

  # GET                   /github/:username(.:format)
  # GET                   /twitter/:username(.:format)
  # GET                   /forrst/:username(.:format)
  # GET                   /dribbble/:username(.:format)
  # GET                   /linkedin/:username(.:format)
  # GET                   /codeplex/:username(.:format)
  # GET                   /bitbucket/:username(.:format)
  # GET                   /stackoverflow/:username(.:format)
  # GET                   /:username(.:format)
  # GET                   /users/:id(.:format)
  def show
    @user = User.find_by_username!(params[:username])

    respond_to do |format|
      format.html do
        @user.skills = Skill.where(user_id: @user.id).order('weight DESC')

        if viewing_user && viewing_user == @user
          viewing_user.track_viewed_self!
        elsif viewing_user
          viewing_user.track_user_view!(@user)
        end

        @user.viewed_by(viewing_user || session_id) unless is_admin? || (signed_in? && viewing_user == @user)
        if @user.pending?
          if (signed_in? && viewing_user == @user)
            flash.now[:notice] = "We're still working on your achievements but you can already start basking in the awesomeness of your new coderwall!"
          else
            flash.now[:notice] = "We're still working on #{@user.display_name}'s achievements, but its not too early to follow and endorse them."
          end
        end
      end

      format.json do
        if stale?(etag: ['v3', @user, user_show_params[:callback], user_show_params[:full]], last_modified: @user.last_modified_at.utc, public: true)
          response = Rails.cache.fetch(['v3', @user, :json, user_show_params[:full]]) do
            @user.public_hash(user_show_params[:full]) do |badge|
              view_context.image_path(badge.image_path) #fully qualified in product
            end.to_json
          end
          response = "#{user_show_params[:callback]}({\"data\":#{response}})" if user_show_params[:callback]
          render json: response
        end
      end
    end
  end

  # GET                   /users(.:format)
  def index
    if signed_in? && current_user.admin?
      return redirect_to(admin_root_url)
    elsif !oauth.blank?
      return redirect_to(new_user_url)
    else
      return redirect_to(root_url)
    end
  end

  # POST                  /users(.:format)
  def create
    @user = User.for_omniauth(oauth)

    ucp = user_create_params.dup

    ucp[:referred_by] = session[:referred_by] unless session[:referred_by].blank?
    ucp[:utm_campaign] = session[:utm_campaign] unless session[:utm_campaign].blank?

    @user.username = ucp[:username] unless ucp[:username].blank? #attr protected

    ucp.delete(:username)

    if @user.update_attributes(ucp)
      @user.complete_registration!
      record_event("signed up", via: oauth[:provider])
      session[:newuser] = nil
      sign_in(@user)
      redirect_to(destination_url)
    else
      render :new
    end
  end

  def delete_account
    return head(:forbidden) unless signed_in?
  end

  def delete_account_confirmed
    user = User.find(current_user.id)
    user.destroy
    sign_out
    redirect_to root_url
  end

  def destroy
    destroy_params = params.permit(:id)
    return head(:forbidden) unless current_user.admin? || current_user.id == destroy_params[:id]

    @user = User.find(destroy_params[:id])
    @user.destroy
    redirect_to badge_url(@user.username)
  end

  # GET                   /settings(.:format)
  def edit
    respond_to do |format|
      format.json do
        settings
      end

      format.html do
        if signed_in?
          @user = user_edit_params[:id].blank? ? current_user : User.find(user_edit_params[:id])
          return head(:forbidden) unless @user == current_user || admin_of_premium_team?
        else
          store_location!
          redirect_to(signin_path)
        end
      end
    end
  end

  # PUT                   /users/:id(.:format)
  def update

    user_id = params[:id]

    @user = user_id.blank? ? current_user : User.find(user_id)

    return head(:forbidden) unless @user == current_user || admin_of_premium_team?

    if @user.update_attributes(user_update_params)
      @user.activate if @user.has_badges? && !@user.active?
      flash.now[:notice] = "The changes have been applied to your profile."
      expire_fragment(@user.daily_cache_key)
    else
      flash.now[:notice] = "There were issues updating your profile."
    end

    respond_to do |format|
      format.js
      format.html do
        if admin_of_premium_team?
          redirect_to(teamname_url(slug: @user.team.slug, full: :preview))
        else
          redirect_to(edit_user_url(@user))
        end
      end
    end

  end

  # POST                  /users/teams_update/:membership_id(.:format)
  def teams_update
    membership=Teams::Member.find(params['membership_id'])
    if membership.update_attributes(teams_member)
      flash.now[:notice] = "The changes have been applied to your profile."
    else
      flash.now[:notice] = "There were issues updating your profile."
    end
    redirect_to(edit_user_url(membership.user))
  end

  # GET                   /users/autocomplete(.:format)
  def autocomplete
    autocomplete_params = params.permit(:query)
    respond_to do |f|
      f.json do
        @users = User.autocomplete(autocomplete_params[:query]).limit(10).sort
        render json: {
          query:       autocomplete_params[:query],
          suggestions: @users.each_with_object([]) { |user, results| results << {
            username:  user.username,
            name:      user.display_name,
            twitter:   user.twitter,
            github:    user.github,
            thumbnail: user.avatar.url
          } },
          data:        @users.collect(&:username)
        }.to_json
      end
    end
  end

  # GET                   /roll-the-dice(.:format)
  def randomize
    random_user = User.random.first
    if random_user
      redirect_to badge_url(random_user.username)
    else
      redirect_to root_url
    end
  end

  # POST                  /users/:id/specialties(.:format)
  def specialties
    @user = current_user
    specialties = params.permit(:specialties)
    @user.update_attribute(:specialties, specialties)
    redirect_to badge_url(@user.username)
  end

  # GET                   /clear/:id/:provider(.:format)
  def clear_provider
    return head(:forbidden) unless current_user.admin?

    clear_provider_params = params.permit(:id, :provider)

    @user = User.find(clear_provider_params[:id])

    clear_provider_for_user(clear_provider_params[:provider], @user)

    redirect_to(badge_url(username: @user.username))
  end

  def settings
    if signed_in?
      record_event("api key requested", username: current_user.username, site: request.env["REMOTE_HOST"])
      render json: { api_key: current_user.api_key }.to_json
    else
      render json: { error: "you need to be logged in to coderwall" }.to_json, status: :forbidden
    end
  end

  # POST                  /github/unlink(.:format)
  # POST                  /twitter/unlink(.:format)
  # POST                  /forrst/unlink(.:format)
  # POST                  /dribbble/unlink(.:format)
  # POST                  /linkedin/unlink(.:format)
  # POST                  /codeplex/unlink(.:format)
  # POST                  /bitbucket/unlink(.:format)
  # POST                  /stackoverflow/unlink(.:format)
  def unlink_provider
    return head(:forbidden) unless signed_in?

    unlink_provider_params = params.permit(:provider)

    provider = unlink_provider_params[:provider]
    clear_provider_for_user(provider, current_user) if current_user.can_unlink_provider?(provider)
    redirect_to(edit_user_url(current_user))
  end

  protected

  def clear_provider_for_user(provider, user)
    case provider
    when 'twitter' then user.clear_twitter!
    when 'github' then user.clear_github!
    when 'linkedin' then user.clear_linkedin!
    else raise("Unknown Provider: '#{provider}'")
    end
  end

  def admin_of_premium_team?
    current_user != @user && @user.team.try(:admin?, current_user)
  end

  helper_method :admin_of_premium_team?

  def track_referrer
    if session[:new_visit] == true && cookies[:identity].blank?
      session[:referred_by] = @user.referral_token unless @user.nil?
    end
  end

  def oauth
    session["oauth.data"]
  end

  def teams_member
    params.require(:teams_member).permit(:title,:team_avatar,:team_banner)
  end

  def user_edit_params
    params.permit(:id)
  end

  def user_update_params
    params.require(:user).permit(:about,
                                 :avatar,
                                 :avatar_cache,
                                 :banner,
                                 :banner_cache,
                                 :bitbucket,
                                 :blog,
                                 :codeplex,
                                 :company,
                                 :dribbble,
                                 :email,
                                 :favorite_websites,
                                 :forrst,
                                 :google_code,
                                 :join_badge_orgs,
                                 :location,
                                 :name,
                                 :notify_on_award,
                                 :notify_on_follow,
                                 :receive_newsletter,
                                 :receive_weekly_digest,
                                 :resume,
                                 :slideshare,
                                 :sourceforge,
                                 :speakerdeck,
                                 :stackoverflow,
                                 :team_avatar,
                                 :team_banner,
                                 :team_responsibilities,
                                 :title,
                                 :username
                                )
  end

  def user_create_params
    params.require(:user).permit(
      :username,
      :name,
      :location,
      :email,
      :referred_by,
      :utm_campaign
    )
  end

  def user_show_params
    params.permit(
      :username,
      :provider,
      :callback,
      :full
    )
  end
end
