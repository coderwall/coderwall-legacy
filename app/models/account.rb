# Postgresed  [WIP] : Teams::Account
require 'stripe'

class Account
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :team

  field :stripe_card_token
  field :stripe_customer_token
  field :admin_id
  field :trial_end, default: nil
  field :plan_ids, type: Array, default: []

  attr_protected :stripe_customer_token, :admin_id

  validate :stripe_customer_token, presence: true
  validate :stripe_card_token, presence: true
  validate :admin_id, :payer_is_team_admin

  def payer_is_team_admin
    if admin_id.nil? #or !team.admin?(admin)
      errors.add(:admin_id, "must be team admin to create an account")
    end
  end

  def subscribe_to!(plan, force=false)
    self.plan_ids = [plan.id]
    if force || update_on_stripe(plan)
      update_job_post_budget(plan)
      self.team.premium     = true unless plan.free?
      self.team.analytics   = plan.analytics
      self.team.upgraded_at = Time.now
    end
    team.save!
  end

  def save_with_payment(plan=nil)
    if valid?
      create_customer unless plan.try(:one_time?)
      subscribe_to!(plan) unless plan.nil?
      team.save!
      return true
    else
      return false
    end
  rescue Stripe::CardError => e
    # Honeybadger.notify(e) if Rails.env.production?
    Rails.logger.error "Stripe error while creating customer: #{e.message}" if ENV['DEBUG']
    errors.add :base, e.message
    return false
  rescue Stripe::InvalidRequestError => e
    # Honeybadger.notify(e) if Rails.env.production?
    Rails.logger.error "Stripe error while creating customer: #{e.message}"  if ENV['DEBUG']
    errors.add :base, "There was a problem with your credit card."
    # throw e if Rails.env.development?
    return false
  end

  def customer
    Stripe::Customer.retrieve(self.stripe_customer_token)
  end

  def admin
    User.find(self.admin_id)
  end

  def create_customer
    new_customer               = find_or_create_customer
    self.stripe_customer_token = new_customer.id
  end

  def find_or_create_customer
    if self.stripe_customer_token
      customer
    else
      Stripe::Customer.create(description: "#{admin.email} for #{self.team.name}", card: stripe_card_token)
    end
  end

  def update_on_stripe(plan)
    if plan.subscription?
      update_subscription_on_stripe!(plan)
    else
      charge_on_stripe!(plan)
    end
  end

  def update_subscription_on_stripe!(plan)
    customer && customer.update_subscription(plan: plan.stripe_plan_id, trial_end: self.trial_end)
  end

  def charge_on_stripe!(plan)
    Stripe::Charge.create(
      amount:      plan.amount,
      currency:    plan.currency,
      card:        self.stripe_card_token,
      description: plan.name
    )
  end

  def update_job_post_budget(plan)
    if plan.free?
      team.paid_job_posts       = 0
      team.monthly_subscription = false
    else
      team.valid_jobs = true

      if plan.subscription?
        team.monthly_subscription = true
      else
        team.paid_job_posts       += 1
        team.monthly_subscription = false
      end
    end
  end

  def suspend!
    team.premium              = false
    team.analytics            = false
    team.paid_job_posts       = 0
    team.monthly_subscription = false
    team.valid_jobs           = false
    team.save
    team.jobs.map { |job| job.deactivate! }
  end

  def add_analytics
    team.analytics = true
  end

  def send_invoice(invoice_id)
    Notifier.invoice(self.team.id, nil, invoice_id).deliver
  end

  def send_invoice_for(time = Time.now)
    Notifier.invoice(self.team.id, time.to_i).deliver
  end

  def invoice_for(time)
    months_ago = ((Time.now.beginning_of_month-time)/1.month).round
    invoices(months_ago).last.to_hash.with_indifferent_access
  end

  def invoices(count = 100)
    Stripe::Invoice.all(
      customer: self.stripe_customer_token,
      count:    count
    ).data
  end

  def current_plan
    Plan.find(self.plan_ids.first) unless self.plan_ids.blank?
  end
end
