class ProtipsController < ApplicationController

  before_action :access_required, only: [:new, :create, :edit, :update, :destroy, :me]
  before_action :require_skills_first, only: [:new, :create]
  before_action :lookup_protip, only: [:show, :edit, :update, :destroy, :upvote, :tag, :flag, :queue, :feature, :delete_tag]
  before_action :reformat_tags, only: [:create, :update]
  before_action :verify_ownership, only: [:edit, :update, :destroy]
  before_action :ensure_single_tag, only: [:subscribe, :unsubscribe]
  before_action :limit_results, only: [:topic, :team, :search, :user, :date]
  before_action :track_search, only: [:search], unless: :is_admin?
  before_action :require_admin!, only: [:feature, :flag, :delete_tag, :admin]
  before_action :determine_scope, only: [:trending, :popular, :fresh, :liked]
  before_action :lookup_user_data, only: [:trending, :popular, :fresh, :liked, :search]

  respond_to :html
  respond_to :json, except: [:show]
  respond_to :js, only: [:subscribe, :unsubscribe, :show]

  layout :choose_protip_layout

  def index
    if !params[:search].blank?
      search
    elsif signed_in?
      trending
    else
      return redirect_to welcome_url
    end
  end

  def trending
    @context = "trending"
    track_discovery
    @protips = cached_version(:trending_score, @scope, search_options)
    find_a_job_for(@protips) unless @protips.empty?
    render :index
  end

  def popular
    @context = "popular"
    track_discovery
    @protips = cached_version(:popular_score, @scope, search_options)
    find_a_job_for(@protips)
    render :index
  end

  def fresh
    redirect_to_signup_if_unauthenticated(protips_path, "You must login/signup to view fresh protips from coders, teams and networks you follow") do
      @context = "fresh"
      track_discovery
      @protips = cached_version(:created_at, @scope, search_options)
      find_a_job_for(@protips)
      render :index
    end
  end

  def liked
    redirect_to_signup_if_unauthenticated(protips_path, "You must login/signup to view protips you have liked/upvoted") do
      @context = "liked"
      track_discovery
      @protips = Protip::Search.new(Protip, Protip::Search::Query.new("upvoters:#{current_user.id}"), @scope, Protip::Search::Sort.new(:created_at), nil, search_options).execute
      find_a_job_for(@protips)
      render :index
    end
  end

  # INVESTIGATE
  # Unused
  # def topic
  #   topic_params = params.permit(:tags, :page, :per_page)
  #
  #   return redirect_to(protips_path) if topic_params[:tags].blank?
  #   tags_array  = topic_params[:tags].split("/")
  #   @protips    = Protip.search_trending_by_topic_tags(nil, tags_array, topic_params[:page], topic_params[:per_page])
  #   @topics     = tags_array.collect { |topic| "<span class='topic-tag' style='border-color:##{topic.to_hex};'>##{topic}</span>" }
  #   @topic      = tags_array.join(' + ')
  #   @topic_user = nil
  # end

  def user
    user_params = params.permit(:username, :page, :per_page)

    user = User.find_by_username(params[:username]) unless params[:username].blank?
    return redirect_to(protips_path) if user.nil?
    @protips    = protips_for_user(user,user_params)
    @topics     = [user.username]
    @topic      = "author:#{user.username}"
    @topic_user = user
    @query      = @topic
    render :topic
  end

  def team
    team_params = params.permit(:team_slug, :page, :per_page)

    team = Team.where(slug: team_params[:team_slug].downcase).first unless team_params[:team_slug].blank?
    return redirect_to(protips_path) if team.nil?
    @protips    = Protip.search_trending_by_team(team.slug, nil, team_params[:page], team_params[:per_page])
    @topics     = [team.slug]
    @topic      = "team:#{team.slug}"
    @topic_user = team
    render :topic
  end

  def date
    date_params = params.permit(:date, :query, :page, :per_page)

    date = Date.current if date_params[:date].downcase == "today"
    date = Date.current.advance(days: -1) if params[:date].downcase == "yesterday"
    date = Date.strptime(date_params[:date], "%m%d%Y") if date.nil?
    return redirect_to(protips_path) unless is_admin? and date
    @protips    = Protip.search_trending_by_date(date_params[:query], date, date_params[:page], date_params[:per_page])
    @topics     = [date.to_s]
    @topic      = date.to_s
    @topic_user = nil
    @query      = "created_at:#{date.to_date.to_s}"
    render :topic
  end

  def me
    me_params = params.permit(:section, :page, :per_page)

    @topics     = @topic = Protip::USER_SCOPE
    section     = me_params[:section]
    query       = "#{section}:#{current_user.username}" if section
    @protips    = Protip.search(query, [], page: me_params[:page], per_page: me_params[:per_page] || 12)
    @topic_user = nil
  end

  def show
    show_params = if is_admin?
                    params.permit(:reply_to, :q, :t, :i, :p)
                  else
                    params.permit(:reply_to)
                  end

    return redirect_to protip_missing_destination, notice: "The pro tip you were looking for no longer exists" if @protip.nil?
    @comments    = @protip.comments
    @reply_to    = show_params[:reply_to]
    @next_protip = Protip.search_next(show_params[:q], show_params[:t], show_params[:i], show_params[:p]) if is_admin?
    @reviewer    = Protip.valid_reviewers.select { |reviewer| @protip.viewed_by?(reviewer) }.first
    @job         = @protip.best_matching_job || Opportunity.uncached { Opportunity.order('RANDOM()').first }
    track_views(@protip)
    respond_with @protip
  end

  def random
    @protip = Protip.random(1).first
    render :show
  end

  def new
    new_params = params.permit(:topics)

    prefilled_topics = (new_params[:topics] || '').split('+').collect(&:strip)
    @protip          = Protip.new(topics: prefilled_topics)
    respond_with @protip
  end

  def edit
    respond_with @protip
  end

  def create
    create_params = if params[:protip] && params[:protip].keys.present?
                      params.require(:protip).permit(:title, :body, :user_id, topics: [])
                    else
                      {}
                    end


    @protip      = Protip.new(create_params)
    @protip.user = current_user
    respond_to do |format|
      if @protip.save
        record_event('created protip')
        format.html { redirect_to protip_path(@protip.public_id), notice: 'Protip was successfully created.' }
        format.json { render json: @protip, status: :created, location: @protip }
      else
        format.html { render action: "new" }
        format.json { render json: @protip.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    # strong_parameters will intentionally fail if a key is present but has an empty hash. :(
    update_params = if params[:protip] && params[:protip].keys.present?
                      params.require(:protip).permit(:title, :body, :user_id, topics: [])
                    else
                      {}
                    end

    #
    # TODO: Ensure that the protip id is the actual id of the logged in user
    #

    respond_to do |format|
      if @protip.update_attributes(update_params)
        format.html { redirect_to protip_path(@protip.public_id), notice: 'Protip was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @protip.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    return head(:forbidden) unless @protip.try(:owned_by?, current_user) || current_user.admin?
    @protip.destroy
    respond_to do |format|
      format.html {
        if request.referer.blank?
          redirect_to protips_url
        else

          if request.referer.include?(@protip.public_id)
            redirect_to protips_url
          else
            redirect_to request.referer
          end
        end
      }
      format.json { head :ok }
    end
  end

  def upvote
    @protip.upvote_by(viewing_user, tracking_code, request.remote_ip)
    @protip
  end

  def tag
    tag_params = params.permit(:topics)
    @protip.topics << tag_params[:topics] unless tag_params[:topics].nil?
  end

  def subscribe
    tags = params.permit(:tags)
    redirect_to_signup_if_unauthenticated(view_context.topic_protips_path(tags)) do
      current_user.subscribe_to(tags)
      respond_to do |format|
        format.json { head :ok }
      end
    end
  end

  def unsubscribe
    tags = params.permit(:tags)
    redirect_to_signup_if_unauthenticated(view_context.topic_protips_path(tags)) do
      current_user.unsubscribe_from(tags)
      respond_to do |format|
        format.json { head :ok }
      end
    end
  end

  def report_inappropriate
    protip_public_id = params[:id]
    if cookies["report_inappropriate-#{protip_public_id}"].nil?
      opts = { user_id: current_user,
               ip: request.remote_ip}
      ::AbuseMailer.report_inappropriate(protip_public_id,opts).deliver

      cookies["report_inappropriate-#{protip_public_id}"] = true
    end

    render  nothing: true
  end

  def flag
    times_to_flag = is_admin? ? Protip::MIN_FLAG_THRESHOLD : 1
    times_to_flag.times do
      @protip.flag
    end
    respond_to do |format|
      if @protip.save
        format.json { head :ok }
      else
        format.json { render json: @protip.errors, status: :unprocessable_entity }
      end
    end
  end

  def unflag
    times_to_flag = is_admin? ? Protip::MIN_FLAG_THRESHOLD : 1
    times_to_flag.times do
      @protip.unflag
    end
    respond_to do |format|
      if @protip.save
        format.json { head :ok }
      else
        format.json { render json: @protip.errors, status: :unprocessable_entity }
      end
    end
  end

  def feature
    #TODO change with @protip.toggle_featured_state!
    if @protip.featured?
      @protip.unfeature!
    else
      @protip.feature!
    end

    respond_to do |format|
      if @protip.save
        format.json { head :ok }
      else
        format.json { render json: @protip.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete_tag
    @protip.topics.delete(CGI.unescape(params.permit(:topic)))
    respond_to do |format|
      if @protip.save
        format.html { redirect_to protip_path(@protip) }
        format.json { head :ok }
      else
        format.html { redirect_to protip_path(@protip) }
        format.json { render json: @protip.errors, status: :unprocessable_entity }
      end
    end
  end

  def admin
    admin_params = params.permit(:page, :per_page)

    @query   = "created_automagically:false only_link:false reviewed:false created_at:[#{Time.new(2012, 8, 22).strftime('%Y-%m-%dT%H:%M:%S')} TO *] sort:created_at asc"
    @protips = Protip.search(@query, [], page: admin_params[:page], per_page: admin_params[:per_page] || 20)

    render :topic
  end

  def by_tags
    by_tags_params = params.permit(:page, :per_page)

    page     = by_tags_params[:page] || 1
    per_page = by_tags_params[:per_page] || 100

    @tags = Tag.joins("inner join taggings on taggings.tag_id = tags.id").group('tags.id').order('count(tag_id) desc').page(page).per(per_page)
  end

  def preview
    preview_params = params.require(:protip).permit(:title, :body)

    preview_params.delete(:topics) if preview_params[:topics].blank?
    protip            = Protip.new(preview_params)
    protip.updated_at = protip.created_at = Time.now
    protip.user       = current_user
    protip.public_id  = "xxxxxx"

    render partial: 'protip', locals: { protip: protip, mode: 'preview', include_comments: false, job: nil }
  end

  def search
    search_params = params.permit(:search)

    @context = 'search'
    query_string, @scope = expand_query(search_params[:search])
    facets = top_tags_facet << Protip::Search::Facet.new('suggested-networks', :terms, :networks, [size: 4])

    @protips = Protip::Search.new(
      Protip,
      Protip::Search::Query.new(query_string),
      @scope,
      Protip::Search::Sort.new(:trending_score),
      facets,
      search_options
    ).execute
    @suggested_networks = suggested_networks
    find_a_job_for(@protips)
    render :index
  end

  private

  # Return protips for a user
  # If the user is banned, grab protips from their association
  # because the tip will have been removed from the search index.
  #
  # @param [ Hash ] params - Should contain :page and :per_page key/values
  def protips_for_user(user,params)
    if user.banned? then user.protips.page(params[:page]).per(params[:per_page])
    else Protip.search_trending_by_user(user.username, nil, [], params[:page], params[:per_page])
    end
  end

  def expand_query(query_string)
    scopes = []
    query  = query_string.nil? ? '' : query_string.dup
    query.scan(/#([\w\.\-#]+)/).flatten.reduce(query) do |query, tag|
      query.slice!("##{tag}")
      scopes << Protip::Search::Scope.new(:network, tag)
      query
    end
    [query, scopes.blank? ? nil : scopes.reduce(&:<<)]
  end

  def lookup_protip
    @protip = if public_id = params[:id]
                Protip.find_by_public_id(public_id.downcase)
              else
                nil
              end
  end

  def choose_protip_layout
    if [:show, :random, :new, :edit, :create, :update].include?(action_name.to_sym)
      'protip'
    elsif [:subscribe, :unsubscribe].include?(action_name.to_sym)
      false
    else
      'application'
    end
  end

  def search_options
    search_options_params = params.permit(:page, :per_page)

    {
      page:     (signed_in? && search_options_params[:page].try(:to_i)) || 1,
      per_page: [(signed_in? && search_options_params[:per_page].try(:to_i)) || 18, Protip::PAGESIZE].min
    }
  end

  def reformat_tags
    tags = params[:protip].delete(:topics)
    params[:protip][:topics] = (tags.is_a?(Array) ? tags : tags.split(",")) unless tags.blank?
  end

  def tagged_user_or_logged_in
    User.where(username: params[:tags]).first || ((params[:tags].nil? and signed_in?) ? current_user : nil)
  end

  def verify_ownership
    lookup_protip
    redirect_to(root_url) unless (is_admin? or (@protip && @protip.owned_by?(current_user)))
  end

  def limit_results
    params[:per_page] = Protip::PAGESIZE if params[:per_page].nil? or (params[:per_page].to_i > Protip::PAGESIZE and !is_admin?)
  end

  def ensure_single_tag
    if params[:tags].split("/").size > 1
      respond_to do |format|
        flash[:error] = "You cannot subscribe to a group of topics"
        format.html { render status: :not_implemented }
      end
    end
  end

  def parse_query(query_string)
    tags  = query_string.scan(/tagged:(?:"(.+)"|(\S+))/i).flatten.compact || []
    query = query_string.dup
    tags.map { |tag| query.slice!("tagged:#{tag}") }
    query.gsub!(Protip::USER_SCOPE_REGEX[:author], "author:#{current_user.username}")
    query.gsub!(Protip::USER_SCOPE_REGEX[:bookmark], "bookmark:#{current_user.username}")
    query.gsub!(/!!/, "author:#{current_user.username} bookmark:#{current_user.username}")
    [query, tags]
  end

  def track_search
    record_event('Protip search', query: params[:search])
  end

  def track_views(protip)
    unless is_admin?
      viewing_user.track_protip_view!(protip) if viewing_user
    end
    protip.viewed_by(viewing_user || session_id)
  end

  def tracking_code
    (current_user && current_user.tracking_code) || cookies[:trc]
  end

  def redirect_to_networks
    redirect_to(networks_path)
  end

  def protip_missing_destination
    signed_in? ? root_path : networks_path
  end

  def determine_scope
    @scope = Protip::Search::Scope.new(:user, current_user) if params[:scope] == "following" && signed_in?
  end

  def private_scope?
    params[:scope] == "following"
  end

  def track_discovery
    record_event('Discover', what: @context, scope: @scope)
  end

  def cached_version(sort, scope, options)
    Rails.cache.fetch(['v2', 'protips_by', sort, *options.to_a.flatten], expires_in: 3.minutes) do
      protips_sorted_by(sort, scope, options)
    end
  end

  def protips_sorted_by(sort, scope, search_opts)
    Protip::Search.new(Protip, nil, scope, Protip::Search::Sort.new(sort), top_tags_facet, search_opts).execute
  end

  def lookup_user_data
    if signed_in? && !request.xhr?
      @upvoted_protips_public_ids = Rails.cache.fetch(['v1', 'upvotes', current_user.id], expires_in: 5.minutes) { current_user.upvoted_protips_public_ids }
    end
  end

  def suggested_networks
    if @protips.respond_to?(:facets)
      @protips.facets['suggested-networks']['terms'].map { |h| h['term'] }
    else
      #gets top 10 tags for the protips and picks up associated networks
      Network.tagged_with(@protips.map(&:tags).flatten.reduce(Hash.new(0)) { |h, t| h[t] += 1; h }.sort_by { |k, v| -v }.first(10).flatten.values_at(*(0..20).step(2))).select(:slug).limit(4).map(&:slug)
    end
  end

  def find_a_job_for(protips)
    return Opportunity.random.first unless protips.present?

    topics = get_topics_from_protips(protips)
    @job   = Opportunity.based_on(topics).to_a.sample || Opportunity.random.first
  end

  def top_tags_facet
    Protip::Search::Facet.new('top-tags', :terms, :tags, [size: 8])
  end

  def get_topics_from_protips(protips)
    if protips.respond_to?(:results) && !protips.facets.blank?
      topics = protips.facets['top-tags']['terms'].map { |h| h['term'] }
    end

    topics = protips.map(&:tags).flatten.uniq.first(8) if topics.blank? && protips.present?
    topics
  end

  def require_skills_first
    if current_user.skills.empty?
      flash[:error] = "Please improve your profile by adding some skills before posting Pro Tips"
      redirect_to badge_path(username: current_user.username, anchor: 'add-skill')
    end
  end
end
