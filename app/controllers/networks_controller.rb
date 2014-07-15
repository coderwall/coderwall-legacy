class NetworksController < ApplicationController
  include ProtipsHelper
  before_filter :lookup_network, only: [:show, :members, :join, :leave, :destroy, :add_tag, :remove_tag, :update_tags, :mayor, :expert, :tag, :current_mayor]
  before_filter :access_required, only: [:new, :create, :edit, :update, :destroy]
  before_filter :require_admin!, only: [:new, :create, :edit, :update, :destroy, :add_tag, :remove_tag, :update_tags]
  before_filter :limit_results, only: [:index, :members, :show, :tag]
  before_filter :set_search_params, only: [:show, :mayor, :expert, :expert, :tag]
  before_filter :redirect_to_search, only: [:show, :tag]
  respond_to :html, :json, :js
  cache_sweeper :follow_sweeper, only: [:join, :leave]

  def new
    @network = Network.new
  end

  def create
    @network = Network.new(params[:network].permit(:name))
    respond_to do |format|
      if @network.save
        format.html { redirect_to networks_path, notice: "#{@network.name} Network was successfully created." }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def index
    @index_networks_params = params.permit(:sort, :action)

    @networks = Rails.cache.fetch('all_networks', expires_in: 1.day) { Network.all }
    if @index_networks_params[:sort] == 'upvotes'
      Rails.cache.fetch('networks_by_upvotes', expires_in: 12.hours) { @networks.sort_by! { |network| -network.upvotes } }
    elsif @index_networks_params[:sort] == 'newmembers'
      Rails.cache.fetch('networks_by_member_count', expires_in: 1.day) { @networks.sort_by! { |network| -network.new_members.count } }
    end
  end

  def members
    render :show
  end

  def show
    @protips = []
    @topics  = @network.tags

    if (params[:sort].blank? && params[:filter].blank?) || params[:sort] == 'upvotes'
      @protips      = @network.most_upvoted_protips(@per_page, @page)
      @query        = 'sort:upvotes desc'
      params[:sort] = 'upvotes'
    elsif params[:sort] == 'new'
      @protips = @network.new_protips(@per_page, @page)
      @query   = 'sort:created_at desc'
    elsif params[:filter] == 'featured'
      @protips = @network.featured_protips(@per_page, @page)
      @query   = 'sort:featured desc'
    elsif params[:filter] == 'flagged'
      ensure_admin!
      @protips = @network.flagged_protips(@per_page, @page)
      @query   = 'sort:flagged desc'
    elsif params[:sort] == 'trending'
      @protips = @network.highest_scored_protips(@per_page, @page, :trending_score)
      @query   = 'sort:trending_score desc'
    elsif params[:sort] == 'hn'
      @protips = @network.highest_scored_protips(@per_page, @page, :trending_hn_score)
      @query   = 'sort:trending_hn_score desc'
    elsif params[:sort] == 'popular'
      @protips = @network.highest_scored_protips(@per_page, @page, :popular_score)
      @query   = 'sort:popular_score desc'
    end
  end

  def tag
    redirect_to network_path(@network.slug) unless @network.nil? || params[:id]
    @networks   = [@network] unless @network.nil?
    tags_array  = params[:tags].nil? ? [] : params[:tags].split('/')
    @query      = 'sort:score desc'
    @protips    = Protip.search_trending_by_topic_tags(@query, tags_array, @page, @per_page)
    @topics     = tags_array
    @topic      = tags_array.join(' + ')
    @topic_user = nil
    @networks   = tags_array.map { |tag| Network.networks_for_tag(tag) }.flatten.uniq if @networks.nil?
  end

  def mayor
    @protips = @network.mayor_protips(@per_page, @page)
    render :show
  end

  def expert
    @protips = @network.expert_protips(@per_page, @page)
    render :show
  end

  def featured
    featured_networks = Network.featured
    if featured_networks.any?
      @networks = featured_networks
    else
      @networks = Network.most_protips.first(7)
    end
    render :index
  end

  def user
    redirect_to_signup_if_unauthenticated(request.referer, 'You must login/signup to view your networks') do
      user      = current_user
      user      = User.with_username(params[:username]) if is_admin?
      @networks = user.networks
      @user     = user
      @index_networks_params = params.permit(:sort, :action)
      render :index
    end
  end

  def join
    redirect_to_signup_if_unauthenticated(request.referer, 'You must login/signup to join a network') do
      return leave if current_user.member_of?(@network)
      current_user.join(@network)
      respond_to do |format|
        format.js { render js: "$('.follow.#{@network.slug}').addClass('followed')" }
      end
    end
  end

  def leave
    redirect_to_signup_if_unauthenticated(request.referer, 'You must login/signup to leave a network') do
      return join unless current_user.member_of?(@network)
      current_user.leave(@network)
      respond_to do |format|
        format.js { render js: "$('.follow.#{@network.slug}').removeClass('followed')" }
      end
    end
  end

  def destroy
    @network.destroy
    respond_to do |format|
      format.json { head :ok }
    end
  end

  def add_tag
    tag = params[:tag]
    @network.tags << tag

    if @network.save
      respond_to do |format|
        format.html { redirect_to network_path(@network.slug) }
        format.json { head :ok }
      end
    end
  end

  def remove_tag
    tag           = params[:tag]
    @network.tags = @network.tags.delete(tag)

    if @network.save
      respond_to do |format|
        format.html { redirect_to network_path(@network.slug) }
        format.json { head :ok }
      end
    end
  end

  def update_tags
    tags          = params[:tags][:tags]
    @network.tags = tags.split(',').map(&:strip).select { |tag| Tag.exists?(name: tag) }

    if @network.save
      respond_to do |format|
        format.html { redirect_to network_path(@network.slug) }
        format.json { head :ok }
      end
    end
  end

  def current_mayor
    @mayor = @network.try(:mayor)
  end

  private
  def lookup_network
    network_name = params[:id] || params[:tags]
    @network     = Network.find_by_slug(Network.slugify(network_name)) unless network_name.nil?
    redirect_to networks_path if @network.nil? && params[:action] != 'tag'
  end

  def limit_results
    params[:per_page] = Protip::PAGESIZE if params[:per_page].nil? || (params[:per_page].to_i > Protip::PAGESIZE && !is_admin?)
  end

  def set_search_params
    @topic    = @network.try(:slug)
    @page     = params[:page] || 1
    @per_page = params[:per_page] || 15
  end

  def featured_from_env
    ENV['FEATURED_NETWORKS'].split(',').map(&:strip) unless ENV['FEATURED_NETWORKS'].nil?
  end

  def ensure_admin!
    redirect_to networks_path unless is_admin?
  end

  def redirect_to_search
    tags = @network.try(:slug).try(:to_a) || (params[:tags] && params[:tags].split('/')) || []
    tags = tags.map { |tag| "##{tag}" }.join(' ')
    redirect_to protips_path(search: tags, show_all: params[:show_all])
  end
end
