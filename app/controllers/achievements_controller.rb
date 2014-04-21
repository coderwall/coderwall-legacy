class AchievementsController < ApplicationController
  before_filter :ensure_valid_api_key, only: [:award]
  skip_before_filter :verify_authenticity_token, only: [:award]
  layout 'protip'

  respond_to :json, only: [:award]

  def show
    @badge = Badge.find(params[:id])
    @user  = @badge.user
    return redirect_to(destination_url) if @badge && @user.username.downcase != params[:username].downcase
  end

  def award
    provider = (User::LINKABLE_PROVIDERS & params.keys).first

    if provider.nil?
      render_404
    else
      if @api_access.can_award?(params[:badge])
        user  = User.with_username(params[provider], provider)
        badge = params[:badge].constantize.new(user, Date.strptime(params[:date], '%m/%d/%Y'))
        badge.generate_fact!(params[:badge], params[provider], provider)
        unless user.nil?
          user.award_and_add_skill badge
          user.save!
        end
        render nothing: true, status: 200
      else
        return render json: { message: "don't have permission to do that. contact support@coderwall.com", status: 403 }.to_json
      end
    end
  rescue Exception => e
    return render json: { message: "something went wrong with your request or the end point may not be ready. contact support@coderwall.com" }.to_json
  end

  private
  def ensure_valid_api_key
    @api_key    = params[:api_key]
    @api_access = ApiAccess.for(@api_key) unless @api_key.nil?
    return render json: { message: "no/invalid api_key provided. get your api_key from coderwall.com/settings" }.to_json if @api_access.nil?
  end


end