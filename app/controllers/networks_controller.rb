class NetworksController < ApplicationController
  include ProtipsHelper
  before_action :lookup_network, only: [:show, :join, :leave]
  before_action :limit_results, only: [:index, :show]
  before_action :set_search_params, only: [:show]
  before_action :redirect_to_search, only: [:show]
  respond_to :html, :json, :js
  cache_sweeper :follow_sweeper, only: [:join, :leave]

  # GET                   /n(.:format)
  def index
    @index_networks_params = params.permit(:sort, :action)

    @networks = Rails.cache.fetch('all_networks', expires_in: 1.day) { Network.all }
    if @index_networks_params[:sort] == 'upvotes'
      Rails.cache.fetch('networks_by_upvotes', expires_in: 12.hours) { @networks.sort_by! { |network| -network.upvotes } }
    elsif @index_networks_params[:sort] == 'newmembers'
      Rails.cache.fetch('networks_by_member_count', expires_in: 1.day) { @networks.sort_by! { |network| -network.new_members.count } }
    end
  end

  #POST                  /n/:id/join(.:format)
  def join
    redirect_to_signup_if_unauthenticated(request.referer, 'You must login/signup to join a network') do
      return leave if current_user.member_of?(@network)
      current_user.join(@network)
      respond_to do |format|
        format.js { render js: "$('.follow.#{@network.slug}').addClass('followed')" }
      end
    end
  end

  # POST                  /n/:id/leave(.:format)
  def leave
    redirect_to_signup_if_unauthenticated(request.referer, 'You must login/signup to leave a network') do
      return join unless current_user.member_of?(@network)
      current_user.leave(@network)
      respond_to do |format|
        format.js { render js: "$('.follow.#{@network.slug}').removeClass('followed')" }
      end
    end
  end

  def show
  end

  private

  def lookup_network
    network_name = params[:id] || params[:tags]
    @network     = Network.find_by_slug(network_name.parameterize) unless network_name.nil?
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

  def redirect_to_search
    tags = @network.try(:slug).try(:split) || (params[:tags] && params[:tags].split('/')) || []
    tags = tags.map { |tag| "##{tag}" }.join(' ')
    redirect_to protips_path(search: tags, show_all: params[:show_all])
  end
end
