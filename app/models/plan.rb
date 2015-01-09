# == Schema Information
#
# Table name: plans
#
#  id                  :integer          not null, primary key
#  amount              :integer
#  interval            :string(255)      default("month")
#  name                :string(255)
#  currency            :string(255)      default("usd")
#  public_id           :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  analytics           :boolean          default(FALSE)
#  interval_in_seconds :integer          default(2592000)
#

require 'stripe'

# TODO
# rename amount to price_in_cents
# rename currency to price_currency

class Plan < ActiveRecord::Base
  has_many :subscriptions , class_name: 'Teams::AccountPlan'

  after_create :register_on_stripe
  after_destroy :unregister_from_stripe

  before_create :generate_public_id

  CURRENCIES = %w(usd)
  MONTHLY = 'month'

  validates :amount, presence: true
  validates :name, presence: true
  validates :currency, inclusion: {in: CURRENCIES}, presence: true

  scope :monthly, -> { where(interval: MONTHLY) }
  scope :one_time, -> { where(interval: nil) }
  scope :paid, -> { where('amount > 0') }
  scope :free, -> { where(amount: 0) }
  scope :with_analytics, -> { where(analytics: true) }
  scope :without_analytics, -> { where(analytics: false) }
  class << self
    def enhanced_team_page_analytics
      monthly.paid.with_analytics.first
    end

    def enhanced_team_page_monthly
      monthly.paid.first
    end

    def enhanced_team_page_one_time
      one_time.paid.first
    end

    def enhanced_team_page_free
      monthly.free.first
    end
  end


  alias_attribute :stripe_plan_id, :public_id

  #copy to sidekiq worker
  def stripe_plan
    Stripe::Plan.retrieve(stripe_plan_id)
  rescue Stripe::InvalidRequestError
    nil
  end


  #sidekiq it
  def register_on_stripe
    if subscription?
      Stripe::Plan.create(
          amount: self.amount,
          interval: self.interval,
          name: self.name,
          currency: self.currency,
          id: self.stripe_plan_id
      )
    end
  rescue Stripe::InvalidRequestError => e
    Rails.logger.error "Stripe error while creating customer: #{e.message}" if ENV['DEBUG']
    errors.add :base, "There was a problem with the plan"
    self.destroy
  end

  #sidekiq it
  def unregister_from_stripe
    if subscription?
      plan_on_stripe = stripe_plan
      plan_on_stripe.try(:delete)
    end
  end

  def price
    amount / 100
  end


  def subscription?
    !one_time?
  end

  def free?
    amount.zero?
  end

  # TODO refactor
  # We should avoid nil.
  def one_time?
    self.interval.nil?
  end

  alias_attribute :has_analytics?, :analytics

  #TODO CHANGE with default in rails 4
  def generate_public_id
    self.public_id = SecureRandom.urlsafe_base64(4).downcase
  end
end
