class ApplicationController < ActionController::Base
  protect_from_forgery

  APP_DOMAIN = 'coderwall.com'

  helper_method :signed_in?
  helper_method :current_user
  helper_method :viewing_self?
  helper_method :is_admin?
  helper_method :viewing_user
  helper_method :round

  before_filter :ensure_domain
  before_filter :apply_flash_message
  before_filter :require_registration
  before_filter :clear_expired_cookie_if_session_is_empty
  before_filter :ensure_and_reconcile_tracking_code
  before_filter :track_utm
  before_filter :show_achievement

  after_filter :record_visit
  after_filter :record_location

  protected

  def apply_flash_message
    flash[:notice] = params[:flash] unless params[:flash].blank?
  end

  def apply_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"]        = "no-cache"
    response.headers["Expires"]       = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def clear_expired_cookie_if_session_is_empty
    if !signed_in?
      cookies.delete(:signedin)
    end
  end

  def current_user
    if @current_user.nil? && session[:current_user]
      @current_user = User.find(session[:current_user])
    end
    @current_user
  end

  def viewing_user
    @viewing_user ||= current_user || begin
      if cookies[:identity]
        User.find_by_username(cookies[:identity])
      end
    end
  end

  def signed_in?
    !current_user.nil?
  end

  def sign_in(user)
    user.track_signin!
    session[:current_user]       = user.id
    cookies[:signedin]           = user.username # this cookie is used by js to show loggedin or not on cached HTML
    cookies.permanent[:identity] = user.username
    current_user.increment!(:login_count)
    current_user.last_ip = request.remote_ip
    current_user.last_ua = request.user_agent
    current_user.save
    ensure_and_reconcile_tracking_code #updated tracking code if appropriate.
    current_user
  end

  def mixpanel_cookie
    mp_cookie = cookies["mp_#{ENV['MIXPANEL_TOKEN']}_mixpanel"]
    if mp_cookie.present?
      JSON.parse(mp_cookie)
    else
      {}
    end
  end

  def ensure_and_reconcile_tracking_code
    if cookies[:trc].blank?
      session[:new_visit] = true
      cookies.permanent[:trc] = mixpanel_cookie['distinct_id']
    end

    if viewing_user
      session[:new_visit] = false
      if viewing_user.tracking_code.blank?
        viewing_user.reload.update_attribute(:tracking_code, cookies[:trc])
      else
        cookies.permanent[:trc] = viewing_user.tracking_code
      end
    end
  end

  def sign_out
    record_event("signed out")
    @current_user          = nil
    session[:current_user] = nil
    cookies.delete(:signedin)
    reset_session
  end

  def store_location!(url = nil)
    session[:return_to] = url || request.url
  end

  def require_registration
    if signed_in? && not_on_pages?
      redirect_to(edit_user_url(current_user)) if !current_user.valid?
    end
  end

  def show_achievement
    if signed_in? && not_on_achievements? && current_user.oldest_achievement_since_last_visit
      redirect_to user_achievement_url(username: current_user.username, id: current_user.oldest_achievement_since_last_visit.id)
    end
  end

  def record_visit
    if viewing_user
      if viewing_user == current_user && (viewing_user.try(:last_request_at) || 1.week.ago) < 1.day.ago && viewing_user.active? && viewing_user.last_refresh_at < 2.days.ago
        Resque.enqueue(RefreshUser, current_user.username)
      end
      viewing_user.visited!
      Usage.page_view(viewing_user.id) unless viewing_user.admin?
    end
  end

  def record_location
    if viewing_user && viewing_user.ip_lat.nil? && deployment_environment?
      Resque.enqueue(ReverseGeolocateUser, viewing_user.username, request.ip)
    end
  end

  def deployment_environment?
    Rails.env.production? or Rails.env.staging?
  end

  def destination_url
    if session[:return_to]
      Rails.logger.debug("Returning user to: #{session[:return_to]}")
      session.delete(:return_to)
    elsif signed_in?
      if current_user.oldest_achievement_since_last_visit
        user_achievement_url(username: current_user.username, id: current_user.oldest_achievement_since_last_visit.id)
      elsif current_user.created_at > 5.minutes.ago
        badge_url(username: current_user.username)
      else
        root_url
      end
    else
      root_url
    end
  end

  def access_required
    redirect_to(root_url) if !signed_in?
  end

  def viewing_self?
    signed_in? && @user && @user == current_user
  end

  def not_on_pages?
    params[:controller] != 'pages'
  end

  def not_on_achievements?
    params[:controller] != 'achievements'
  end

  unless Rails.env.development? || Rails.env.test?
    rescue_from(ActiveRecord::RecordNotFound) { |e| render_404 }
    rescue_from(ActionController::RoutingError) { |e| render_404 }
    # rescue_from(RuntimeError) { |e| render_500 }
  end

  def render_404
    respond_to do |type|
      type.html { render file: File.join(Rails.root, 'public', '404.html'), layout: nil, status: 404 }
      type.all { render nothing: true, status: 404 }
    end
  end

  def render_500
    respond_to do |type|
      type.html { render file: File.join(Rails.root, 'public', '500.html'), layout: nil, status: 500 }
      type.all { render nothing: true, status: 500 }
    end
  end

  def require_admin!
    return head(:forbidden) unless signed_in? && current_user.admin?
  end

  def is_admin?
    signed_in? && current_user.admin?
  end

  def iphone_user_agent?
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
  end

  def round(number)
    if number < 10
      number.round
    elsif number < 100
      number.round(-1)
    elsif number < 1000
      number.round(-2)
    elsif number < 10000
      number.round(-3)
    else
      number.round(-Math.log(number, 10))
    end
  end

  def record_event(action_name, options = {})
    if !signed_in? || !current_user.admin?
      options.merge!('mp_name_tag' => cookies[:identity]) unless cookies[:identity].blank?
      options.merge!('distinct_id' => cookies[:trc]) unless cookies[:trc].blank?
      unless current_user.nil?
        options.merge!({ 'score'           => current_user.score.round(-1),
                         'followers'       => round(current_user.followers_count),
                         'achievements'    => current_user.badges_count,
                         'on team'         => current_user.on_team?,
                         'premium team'    => (current_user.team && current_user.team.premium?) || false,
                         'signed in'       => true,
                         'member'          => true,
                         'first visit'     => false,
                         'visit frequency' => current_user.visit_frequency })
      else
        options.merge!({ 'signed in'   => false,
                         'member'      => cookies[:identity] && User.exists?(username: cookies[:identity]),
                         'first visit' => session[:new_visit]
        })
      end

      #options.merge!('signed up on' => current_user.created_at.to_formatted_s(:mixpanel),
      #               'achievements' => current_user.badges_count) if signed_in?

      Resque.enqueue(MixpanelTracker::TrackEventJob, action_name, options, request.ip) if ENABLE_TRACKING
    end
  rescue Exception => ex
    Rails.logger.error("MIXPANEL: Swallowing error when trying to record #{action_name}, #{ex.message}")
  end

  def session_id
    request.session_options[:id]
  end

  def ensure_domain
    if Rails.env.production?
      if request.env['HTTP_HOST'] != APP_DOMAIN
        redirect_to request.url.sub("//www.", "//"), status: 301
      end
    end
  end

  def track_utm
    session[:utm_campaign] = params[:utm_campaign] unless params[:utm_campaign].blank?
  end

  def ajax_redirect_to(uri)
    respond_to do |format|
      format.json do
        render json: {
          status: :redirect,
          to:     uri
        }.to_json
      end
    end
  end

  def redirect_to_path(path)
    if request.xhr?
      ajax_redirect_to(path)
    else
      redirect_to path
    end
  end

  def redirect_to_signup_if_unauthenticated(return_to=request.referer, message = "You must be signed in to do that", &block)
    if signed_in?
      yield
    else
      flash[:notice] = message
      #This is called when someone tries to do an action while unauthenticated
      Rails.logger.info "WILL RETURN TO #{return_to}"
      store_location!(return_to)
      redirect_to_path(signin_path)
    end
  end

  unless ENV['HTTP_BASICAUTH_ON'].blank?
    before_filter :require_http_basic

    def require_http_basic
      authenticate_or_request_with_http_basic do |username, password|
        username == ENV['HTTP_BASICAUTH_USERNAME'] && password == ENV['HTTP_BASICAUTH_PASSWORD']
      end
    end
  end

end
