class Subscription < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  add_template_helper(UsersHelper)
  add_template_helper(ProtipsHelper)

  layout 'email'

  default_url_options[:host] = "coderwall.com"
  default_url_options[:only_path] = false
  default from: '"Coderwall" <support@coderwall.com>'

  MONTHLY_SUBSCRIPTION_PURCHASED_EVENT = 'monthly_subscription_purchased'
  ONETIME_SUBSCRIPTION_PURCHASED_EVENT = 'onetime_subscription_purchased'

  def team_upgrade(username, plan_id)
    plan = Plan.find(plan_id)
    event = subscription_event(plan)
    headers['X-Mailgun-Variables'] = {email_type: event}.to_json
    track_campaign(event)

    @user = User.find_by_username(username)
    @user.touch(:last_email_sent)
    @plan = plan
    @capability = plan_capability(plan)

    mail to: @user.email, subject: "Your Coderwall Enhanced Team subscription for #{@user.team.name}"
  end

  #if Rails.env.development?
    #class Preview < MailView
      #def team_upgrade
        #user = User.on_team.order("Random()").first
        #mail = Subscription.team_upgrade(user.username, Plan.enhanced_team_page_monthly.id)
        #mail
      #end
    #end
  #end

  private
  def track_campaign(id)
    headers['X-Mailgun-Campaign-Id'] = id
  end

  def subscription_event(plan)
    plan.subscription? ? MONTHLY_SUBSCRIPTION_PURCHASED_EVENT : ONETIME_SUBSCRIPTION_PURCHASED_EVENT
  end

  def plan_capability(plan)
    message = ""
    if plan.subscription?
      message = "You can now post up to 4 jobs at any time"
    elsif plan.one_time?
      message = "You can now post one job for 30 days"
    end
    message
  end
end
