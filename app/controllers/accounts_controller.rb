class AccountsController < ApplicationController
  layout 'product_description'
  skip_before_action :verify_authenticity_token, only: [:webhook]
  before_action :lookup_account, except: [:webhook, :send_invoice]
  before_action :ensure_account_admin, except: [:create]
  before_action :determine_plan, only: [:create, :update]
  before_action :ensure_eligibility, only: [:new]

  # GET                   /teams/:team_id/account/new(.:format)
  def new
    @account ||= current_user.team.build_account
    @plan    = params[:public_id]
  end

  # POST                  /teams/:team_id/account(.:format)
  def create
    redirect_to teamname_path(slug: @team.slug) if @plan.free?

    @account = @team.build_account(account_params)

    if @account.save_with_payment(@plan)
      unless @team.is_member?(current_user)
        @team.add_member(current_user,:active)
      end
      record_event('upgraded team')

      SubscriptionMailer.team_upgrade(current_user.username, @plan.id).deliver
      redirect_to new_team_opportunity_path(@team), notice: "You are subscribed to #{@plan.name}." + plan_capability(@plan, @team)
    else
      Rails.logger.error "Error creating account #{@account.errors.inspect}"
      flash[:error] = @account.errors.full_messages.join("\n")
      redirect_to employers_path
    end
  end

  # PUT                   /teams/:team_id/account(.:format)
  def update
    if @account.update_attributes(account_params) && @account.save_with_payment(@plan)
      redirect_to new_team_opportunity_path(@team), notice: "You are subscribed to #{@plan.name}." + plan_capability(@plan, @team)
    else
      flash[:error] = @account.errors.full_messages.join("\n")
      redirect_to employers_path
    end
  end

  # GET                   /webhooks/stripe(.:format)
  def webhook
    data = JSON.parse request.body.read
    if data[:type] == "invoice.payment_succeeded"
      invoice_id  = data['data']['object']['id']
      customer_id = data['data']['object']['customer']
      team        = Team.where('account.stripe_customer_token' => customer_id).first

      unless data['paid']
        team.account.suspend!
      else
        team.account.send_invoice(invoice_id)
      end
    end
  end

  # POST                  /teams/:team_id/account/send_invoice(.:format)
  def send_invoice
    team, period = Team.find(params[:team_id]), 1.month.ago

    if team.account.send_invoice_for(period)
      flash[:notice] = "sent invoice for #{period.strftime("%B")} to the team's admins "
    else
      flash[:error] = 'There was an error in sending an invoice'
    end

    redirect_to teamname_path(slug: team.slug)
  end

  private
  def lookup_account
    begin
      @team = Team.includes(:account).find(params[:team_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to employers_path if @team.nil?
    end
    @account = @team.account
  end

  def ensure_account_admin
    is_admin? || @team.admins.exists?(user_id: current_user)
  end

  def determine_plan
    chosen_plan = params[:teams_account].delete(:chosen_plan)
    @plan       = Plan.find_by_public_id(chosen_plan)
  end

  def ensure_eligibility
    return redirect_to(teamname_path(@team.slug), notice: "you must complete at least 6 sections of the team profile before posting jobs") unless @team.has_specified_enough_info?
  end

  def plan_capability(plan, team)
    message = ""
    if plan.subscription?
      message = "You can now post up to #{team.number_of_jobs_to_show} jobs at any time"
    elsif plan.one_time?
      message = "You can now post one job for 30 days"
    end
    message
  end

  def account_params
    params.require(:teams_account).permit(:stripe_card_token)
  end

end
