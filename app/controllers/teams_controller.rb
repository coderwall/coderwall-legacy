class TeamsController < ApplicationController
  skip_before_action :require_registration, :only => [:accept, :record_exit]
  before_action :access_required, :except => [:index, :show, :new, :inquiry, :search, :create, :record_exit]
  before_action :ensure_analytics_access, :only => [:visitors]
  respond_to :js, :only => [:search, :create, :approve_join, :deny_join]
  respond_to :json, :only => [:search]

  # GET                   /teams(.:format)
  def index
    current_user.seen(:teams) if signed_in?
    #@featured_teams = Rails.cache.fetch(Team::FEATURED_TEAMS_CACHE_KEY, expires_in: 4.hours) do
    @featured_teams = Team.featured.sort_by(&:relevancy).reject do |team|
      team.jobs.count == 0
    end.reverse!
    #end
    @teams = []
  end

  # GET                   /teams/followed(.:format)
  def followed
    @teams = current_user.teams_being_followed
  end

  # GET                   /team/:slug(/:job_id)(.:format)
  # GET                   /team/:slug(.:format)
  def show
    #FIXME
    show_params = params.permit(:job_id, :refresh, :callback, :id, :slug)
    @team ||= team_from_params(slug: show_params[:slug], id: show_params[:id])
    return render_404 unless @team

    respond_to do |format|
      format.html do

        @team_protips = @team.trending_protips(4)
        @query = "team:#{@team.slug}"
        viewing_user.track_team_view!(@team) if viewing_user
        @team.viewed_by(viewing_user || session_id) unless is_admin?
        @job = show_params[:job_id].nil? ? @team.jobs.sample : Opportunity.find_by_public_id(show_params[:job_id])

        @other_jobs = @team.jobs.reject { |job| job.id == @job.id } unless @job.nil?
        @job_page = !@job.nil?
        return render(:premium) if show_premium_page?
      end

      format.json do
        options = { :expires_in => 5.minutes }
        options[:force] = true if !show_params[:refresh].blank?
        response = Rails.cache.fetch(['v1', 'team', show_params[:id], :json], options) do
            @team.public_json
        end
        response = "#{show_params[:callback]}({\"data\":#{response}})" if show_params[:callback]
        render :json => response
      end
    end
  end

  # GET                   /teams/new(.:format)
  def new
    return redirect_to employers_path
  end

  # POST                  /teams(.:format)
  def create
    team_params = params.require(:team).permit(:name, :slug, :show_similar, :join_team)
    team_name = team_params.fetch(:name, '')

    @teams = Team.with_similar_names(team_name)
    if team_params[:show_similar] == 'true' && !@teams.empty?
      @new_team_name = team_name
      render 'similar_teams' and return
    end

    if team_params[:join_team] == 'true'
      @team = Team.where(slug: team_params[:slug]).first
      render :create and return
    end

    @team = Team.new(name: team_name)
    if @team.save
      record_event('created team')
      @team.add_user(current_user, 'active', 'admin')

      flash.now[:notice] = "Successfully created a team #{@team.name}"
    else
      message = @team.errors.full_messages.join("\n")
      flash[:error] = "There was an error in creating a team #{@team.name}\n#{message}"
    end
  end

  #def team_to_regex(team)
  #team.name.gsub(/ \-\./, '.*')
  #end

  # GET                   /team/:slug/edit(.:format)
  def edit
    @team = Team.find_by_slug(params[:slug])
    return head(:forbidden) unless current_user.belongs_to_team?(@team) || current_user.admin?
    @edit_mode = true
    show
  end

  #                             PUT                   /teams/:id(.:format)                                   teams#update
  def update
    update_params = params.permit(:id, :_id, :job_id, :slug)
    update_team_params = params.require(:team).permit!
    @section_id = (params.permit(:section_id) || {})[:section_id]

    @team = Team.find(update_params[:id])
    return head(:forbidden) unless current_user.belongs_to_team?(@team) || current_user.admin?
    update_team_params.delete(:id)
    update_team_params.delete(:_id)
    @team.update_attributes(update_team_params)
    @edit_mode = true
    # @team.edited_by(current_user)
    @job = if update_params[:job_id].nil?
             @team.jobs.sample
           else
             Opportunity.find_by_public_id(update_params[:job_id])
           end

    if @team.save
      respond_with do |format|
        format.html { redirect_to(teamname_url(:slug => @team.slug)) }
        format.js
      end
    else
      respond_with do |format|
        format.html { render(:action => :edit) }
        #FIXME
        format.js { render(json: {errors: @team.errors.full_messages} , status: :unprocessable_entity) }
      end
    end
  end

  # POST                  /teams/:id/follow(.:format)
  def follow
    # TODO move to concern
    @team = if params[:id].present? && (params[:id].to_i rescue nil)
              Team.find(params[:id].to_i)
            else
              Team.where(slug: params[:id]).first
            end

    if current_user.following_team?(@team)
      current_user.unfollow_team!(@team)
    else
      current_user.follow_team!(@team)
    end
    respond_to do |format|
      format.json { render json: { dom_id: dom_id(@team), following: current_user.following_team?(@team) } }
      format.js { render json: { dom_id: dom_id(@team), following: current_user.following_team?(@team) } }
    end
  end

  # GET                   /employers(.:format)
  def upgrade
    upgrade_params = params.permit(:discount)

    current_user.seen(:product_description)
    @team = current_user.membership.try(:team) || Team.new

    if upgrade_params[:discount] == ENV['DISCOUNT_TOKEN']
      session[:discount] = ENV['DISCOUNT_TOKEN']
    end
    render :layout => 'product_description'
  end

  # POST                  /teams/inquiry(.:format)
  def inquiry
    inquiry_params = params.permit(:email, :company)

    current_user.seen(:inquired) if signed_in?
    record_event('inquired about team page')
    NotifierMailer.new_lead(current_user.try(:username), inquiry_params[:email], inquiry_params[:company]).deliver
    render :layout => 'product_description'
  end

  # GET                   /teams/:id/accept(.:format)
  def accept
    apply_cache_buster

    accept_params = params.permit(:id, :r, :email)

    @team = Team.find(accept_params[:id])
    if accept_params[:r] && @team.has_user_with_referral_token?(accept_params[:r])
      @team.add_member(current_user, 'active')
      current_user.update_attribute(:referred_by, accept_params[:r]) if current_user.referred_by.nil?
      flash[:notice] = "Welcome to team #{@team.name}"
      record_event("accepted team invite")
    else
      @invites = Invitation.where(:email => [accept_params[:email], current_user.email]).all
      @invites.each do |invite|
        if invite.for?(@team)
          invite.accept!(current_user)
        else
          invite.decline!(current_user)
        end
      end
    end
    redirect_to teamname_url(:slug => current_user.reload.team.slug)
  end

  # GET                   /teams/search(.:format)
  def search
    search_params = params.permit(:q, :country, :page)

    @teams = Team.search(search_params[:q], search_params[:country], (search_params[:page].to_i || 1), 30)
    respond_with @teams
  end

  # POST                  /teams/:id/record-exit(.:format)
  def record_exit
    record_exit_params = params.permit(:id, :exit_url, :exit_target_type, :furthest_scrolled, :time_spent)

    unless is_admin?
      @team = Team.find(record_exit_params[:id])
      @team.record_exit(viewing_user || session_id, record_exit_params[:exit_url], record_exit_params[:exit_target_type], record_exit_params[:furthest_scrolled], record_exit_params[:time_spent])
    end
    render :nothing => true
  end

  # GET                   /teams/:id/visitors(.:format)
  def visitors
    since = is_admin? ? 0 : 2.weeks.ago.to_i
    full = is_admin? && params[:full] == 'true'
    @visitors = @team.aggregate_visitors(since).reject { |visitor| visitor[:user] && @team.on_team?(visitor[:user]) }
    @visitors = @visitors.first(75) if !is_admin? || !full
    @views = @team.total_views
    @impressions = @team.impressions
    render :analytics unless full
  end

  # POST                  /teams/:id/join(.:format)
  def join
    join_params = params.permit(:id)

    redirect_to_signup_if_unauthenticated(request.referer, "You must be signed in to request to join a team") do
      @team = Team.find(join_params[:id])
      @team.request_to_join(current_user)
      @team.save
      redirect_to teamname_path(:slug => @team.slug), :notice => "We have submitted your join request to the team admin to approve"
    end
  end

  # POST                  /teams/:id/join/:user_id/approve(.:format)
  def approve_join
    approve_join_params = params.permit(:id, :user_id)

    @team = Team.find(approve_join_params[:id])
    return head(:forbidden) unless @team && @team.admin?(current_user)
    @team.approve_join_request(User.find(approve_join_params[:user_id].to_i))
    @team.save
    render :join_response
  end

  # POST                  /teams/:id/join/:user_id/deny(.:format)
  def deny_join
    deny_join_params = params.permit(:id, :user_id)

    @team = Team.find(deny_join_params[:id])
    return head(:forbidden) unless @team && @team.admin?(current_user)
    @team.deny_join_request(User.find(deny_join_params[:user_id].to_i))
    @team.save
    render :join_response
  end

  protected

  def team_from_params(opts)
    if opts[:slug].present?
      Team.where(slug: opts[:slug].downcase).first
    else
      if valid_id?(opts[:id])
        Team.find(opts[:id])
      else
        nil
      end
    end
  end

  def valid_id?(id)
    id.to_i.to_s == id && id.to_i < 2147483647
  end

  def replace_section(section_name)
    section_name = section_name.tr('-', '_')
    "$('##{section_name}').replaceWith('#{escape_javascript(render(:partial => section_name))}');"
  end

  def show_premium_page?
    true
  end

  def team_edit_view
    if @team.premium?
      @editing_team = true
      :premium
    else
      :edit
    end
  end

  def page_based_on_rank(rank)
    (rank / 25) + 1
  end

  def job_public_ids
    Rails.cache.fetch('all-jobs-public-ids', :expires_in => 1.hour) { Opportunity.group('team_id, created_at, public_id').pluck(:public_id) }
  end

  def next_job(job)
    jobs = job_public_ids
    public_id = job && jobs[(jobs.index(job.public_id) || -1)+1]
    Opportunity.find_by_public_id(public_id) unless public_id.nil?
  end

  def previous_job(job)
    jobs = job_public_ids
    public_id = job && jobs[(jobs.index(job.public_id) || +1)-1]
    Opportunity.find_by_public_id(public_id) unless public_id.nil?
  end

  def ensure_analytics_access
    @team = Team.find(params[:id])
    return redirect_to team_path(@team) unless (@team.analytics? && @team.admin?(current_user)) || is_admin?
  end
end
