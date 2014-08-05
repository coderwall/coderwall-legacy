class EventsController < ApplicationController
  before_action :access_required
  before_action :limit_count, only: [:more]
  before_action :track_request, only: [:more], unless: :is_admin?
  before_action :find_user, only: [:index, :more]
  respond_to :html, :json, :js

  def index
    ap @user.subscribed_channels
    ap @user.subscribed_channels.to_json


    @subscribed_channels = @user.subscribed_channels.to_json

    ap @user.activity_stats
    ap @user.activity_stats.to_json

    @stats               = @user.activity_stats.to_json
  end

  def more
    from = params[:since].try(:to_f) || 0
    to   = Time.now.to_f

    Event.user_activity(@user, from, to, @count, true)
    respond_with @user.activity_stats
  end

  private

  def track_request
  end

  def limit_count
    @count = params[:count].nil? ? 5 : [params[:count].to_i, 10].min
  end

  def verify_ownership
    redirect_to(root_url) unless (params[:username] == current_user.username)
  end

  def find_user
    @user = current_user
  end

  def find_featured_protips
    if Rails.env.development? && ENV['FEATURED_PROTIPS'].blank?
      ENV['FEATURED_PROTIPS'] = Protip.limit(3).collect(&:public_id).join(',')
    end
    return [] if ENV['FEATURED_PROTIPS'].blank?
    Protip.where(public_id: ENV['FEATURED_PROTIPS'].split(','))
  end
end
