# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `purchased_bundles`
#
# ### Columns
#
# Name                       | Type               | Attributes
# -------------------------- | ------------------ | ---------------------------
# **`charity_proceeds`**     | `integer`          |
# **`coderwall_proceeds`**   | `integer`          |
# **`codeschool_coupon`**    | `string(255)`      |
# **`codeschool_proceeds`**  | `integer`          |
# **`created_at`**           | `datetime`         |
# **`credit_card_id`**       | `string(255)`      |
# **`email`**                | `string(255)`      |
# **`id`**                   | `integer`          | `not null, primary key`
# **`peepcode_coupon`**      | `string(255)`      |
# **`peepcode_proceeds`**    | `integer`          |
# **`recipes_coupon`**       | `string(255)`      |
# **`stripe_customer_id`**   | `string(255)`      |
# **`stripe_purchase_id`**   | `string(255)`      |
# **`stripe_response`**      | `text`             |
# **`total_amount`**         | `integer`          |
# **`updated_at`**           | `datetime`         |
# **`user_id`**              | `integer`          |
#

class PurchasedBundle < ActiveRecord::Base
  extend ResqueSupport::ActiveModel
  attr_accessor :token

  @queue = 'HIGH'

  before_validation :split_purchase
  after_create :queue_delivery!

  validates_numericality_of :total_amount, greater_than_or_equal_to: 2000, message: "must be at least $20"
  validates_presence_of :email
  validates_format_of :email, with: /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i
  validate :card_charged, on: :create
  validates_presence_of :stripe_purchase_id
  validates_presence_of :stripe_customer_id

  def self.create_test_token
    token = Stripe::Token.create(card: {
      number:    "4242424242424242",
      exp_month: 7,
      exp_year:  2020,
      cvc:       314 })
    token[:id]
  end

  def fee
    (total_amount * 0.029) + 30
  end

  def send_reciept!
    transaction do
      coupon = AvailableCoupon.first
      update_attributes!(
        peepcode_coupon:   coupon.peepcode_coupon,
        codeschool_coupon: coupon.codeschool_coupon,
        recipes_coupon:    coupon.recipes_coupon
      )
      coupon.delete
      if Rails.env.development?
        Notifier.deliver_bundle(self.id).deliver
      else
        Notifier.deliver_bundle(self.id).deliver!
      end
    end
  end

  def total
    total_amount.to_f / 100
  end

  def donation
    charity_proceeds.to_f / 100
  end

  def queue_delivery!
    if Rails.env.development?
      send_reciept!
    else
      async(:send_reciept!)
    end
  end

  protected

  def card_charged
    raise "Token is nil" if token.nil?
    return nil if email.blank? && total_amount.to_i <= 0
    customer = Stripe::Customer.create(card: token, description: email)
    charge   = Stripe::Charge.create(amount: total_amount, currency: "usd", customer: customer.id, description: "Coderwall Javascript Bundle for #{email}")
    if charge.paid
      self.stripe_purchase_id = charge.id
      self.stripe_customer_id = customer.id #needs to be string
      self.stripe_response    = charge.to_json
    else
      errors[:base] << "Unable to charge card. Please contact us at #{ENV['SUPPORT_EMAIL']} if you continue to have issues."
    end
  rescue Exception => ex
    Rails.logger.error(ex)
    errors[:base] << "Unable to charge card. Please contact us at #{ENV['SUPPORT_EMAIL']} if you continue to have issues."
  end

  def split_purchase
    self.total_amount        = 0 if self.total_amount.nil?
    self.peepcode_proceeds   = ((total_amount - fee) * 0.13)
    self.codeschool_proceeds = ((total_amount - fee) * 0.60)
    self.charity_proceeds    = ((total_amount - fee) * 0.20)
    self.coderwall_proceeds  = total_amount - (peepcode_proceeds + codeschool_proceeds + charity_proceeds + fee)
  end
end
