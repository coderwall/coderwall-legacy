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
    Rails.logger.error "Stripe error while creating customer: #{e.message}"  if ENV['DEBUG']
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

# == Schema Information
# Schema version: 20140713193201
#
# Table name: plans
#
#  id         :integer          not null, primary key
#  amount     :integer
#  interval   :string(255)
#  name       :string(255)
#  currency   :string(255)
#  public_id  :string(255)
#  created_at :datetime
#  updated_at :datetime
#  analytics  :boolean          default(FALSE)
#
