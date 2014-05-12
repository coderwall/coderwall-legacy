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

require 'spec_helper'

describe PurchasedBundle do

  it 'should split purchase amount on creation', functional: true do
    purchase = create_test_bundle(amount = 6000)
    purchase.codeschool_proceeds.should == 3477 #3600
    purchase.charity_proceeds.should == 1159 #1200
    purchase.coderwall_proceeds.should == 1160 #420
  end

  it 'should not allow purchases under 20 dollars', functional: true do
    purchase = create_test_bundle(amount = 1999)
    purchase.should_not be_valid
    purchase.errors.full_messages.should include("Total amount must be at least $20")
  end

  it 'must have an email address', functional: true do
    bundle = PurchasedBundle.new
    bundle.should_not be_valid
    bundle.errors.full_messages.should include("Email can't be blank")
  end

  it 'should put stripe message into errors if charge unsucessful', functional: true do
    purchase = create_test_bundle(amount = 2000, bad_token = 'this-is-bogus')
    purchase.errors.full_messages.should include("Unable to charge card. Please contact us at support@coderwall.com if you continue to have issues.")
  end

  def create_test_bundle(amount, token = PurchasedBundle.create_test_token)
    PurchasedBundle.create do |bundle|
      bundle.total_amount = amount
      bundle.email = Faker::Internet.email
      bundle.user_id = Faker::Internet
      bundle.token = token
    end
  end
end
