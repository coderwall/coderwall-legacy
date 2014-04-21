# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `available_coupons`
#
# ### Columns
#
# Name                     | Type               | Attributes
# ------------------------ | ------------------ | ---------------------------
# **`codeschool_coupon`**  | `string(255)`      |
# **`id`**                 | `integer`          | `not null, primary key`
# **`peepcode_coupon`**    | `string(255)`      |
# **`recipes_coupon`**     | `string(255)`      |
#
# ### Indexes
#
# * `index_available_coupons_on_codeschool_coupon` (_unique_):
#     * **`codeschool_coupon`**
# * `index_available_coupons_on_peepcode_coupon` (_unique_):
#     * **`peepcode_coupon`**
#

class AvailableCoupon < ActiveRecord::Base
end
