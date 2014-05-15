class AchievementsController < ApplicationController
  before_filter :ensure_valid_api_key, only: [:award]
  skip_before_filter :verify_authenticity_token, only: [:award]
  layout 'protip'

  respond_to :json, only: [:award]

  def show
    show_achievements_params = params.permit(:id, :username)

    @badge = Badge.find(show_achievements_params[:id])
    @user  = @badge.user
    return redirect_to(destination_url) if @badge && @user.username.downcase != show_achievements_params[:username].downcase
  end

  def award

    award_params = params.permit(:badge, :twitter, :linkedin, :github, :date)

    provider = pick_a_provider(award_params)

    if provider.nil?
      render_404
    else
      if @api_access.can_award?(award_params[:badge])
        user  = User.with_username(award_params[provider], provider)
        badge = badge_class_factory(award_params[:badge].to_s).new(user, Date.strptime(award_params[:date], '%m/%d/%Y'))
        badge.generate_fact!(award_params[:badge], award_params[provider], provider)
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
    @api_key    = params.permit(:api_key)[:api_key]
    @api_access = ApiAccess.for(@api_key) unless @api_key.nil?
    return render json: { message: "no/invalid api_key provided. get your api_key from coderwall.com/settings" }.to_json if @api_access.nil?
  end

  def badge_class_factory(requested_badge_name)
    BADGES_LIST.select { |badge_name| badge_name == requested_badge_name }.first.constantize
  end

  def pick_a_provider(award_params)
    (User::LINKABLE_PROVIDERS & award_params.keys.select { |key| %w{twitter linkedin github}.include?(key) }).first
  end
end
