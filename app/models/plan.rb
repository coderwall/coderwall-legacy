# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `plans`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`amount`**      | `integer`          |
# **`analytics`**   | `boolean`          | `default(FALSE)`
# **`created_at`**  | `datetime`         |
# **`currency`**    | `string(255)`      |
# **`id`**          | `integer`          | `not null, primary key`
# **`interval`**    | `string(255)`      |
# **`name`**        | `string(255)`      |
# **`public_id`**   | `string(255)`      |
# **`updated_at`**  | `datetime`         |
#

require 'stripe'

class Plan < ActiveRecord::Base
  has_many :subscriptions

  after_create :register_on_stripe
  after_destroy :deregister_on_stripe

  before_validation :set_currency
  before_create :generate_public_id

  CURRENCIES = %w(usd)
  MONTHLY    = 'month'

  validate :amount, presence: true
  validate :name, presence: true
  validate :currency, inclusion: { in: CURRENCIES }

  class << self
    def enhanced_team_page_analytics
      Plan.where(interval: MONTHLY).where('amount > 0').where(analytics: true).first
    end

    def enhanced_team_page_monthly
      Plan.where(interval: MONTHLY).where('amount > 0').first
    end

    def enhanced_team_page_one_time
      Plan.where(interval: nil).where('amount > 0').first
    end

    def enhanced_team_page_free
      Plan.where(interval: MONTHLY).where(amount: 0).first
    end

    def seed_plans!(reset=false)
      Plan.destroy_all if reset
      Plan.create(amount: 0, interval: Plan::MONTHLY, name: "Basic") if enhanced_team_page_free.nil?
      Plan.create(amount: 9900, interval: Plan::MONTHLY, name: "Monthly") if enhanced_team_page_monthly.nil?
      Plan.create(amount: 19900, interval: nil, name: "Single") if enhanced_team_page_one_time.nil?
      Plan.create(amount: 19900, interval: Plan::MONTHLY, analytics: true, name: "Analytics") if enhanced_team_page_analytics.nil?
    end

  end

  def register_on_stripe
    if subscription?
      Stripe::Plan.create(
        amount:   self.amount,
        interval: self.interval,
        name:     self.name,
        currency: self.currency,
        id:       self.stripe_plan_id
      )
    end
  rescue Stripe::InvalidRequestError => e
    Rails.logger.error "Stripe error while creating customer: #{e.message}"
    errors.add :base, "There was a problem with the plan"
    self.destroy
  end

  def price
    amount / 100
  end

  def deregister_on_stripe
    if subscription?
      plan_on_stripe = stripe_plan
      plan_on_stripe.try(:delete)
    end
  end

  def stripe_plan
    Stripe::Plan.retrieve(stripe_plan_id)
  rescue Stripe::InvalidRequestError
    nil
  end

  def stripe_plan_id
    self.public_id
  end

  def set_currency
    self.currency = 'usd'
  end

  def subscription?
    not one_time?
  end

  def free?
    self.amount == 0
  end

  def one_time?
    self.interval.nil?
  end

  def has_analytics?
    self.analytics
  end

  def generate_public_id
    self.public_id = SecureRandom.urlsafe_base64(4).downcase
  end
end
