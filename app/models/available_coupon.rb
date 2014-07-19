class AvailableCoupon < ActiveRecord::Base
end

# == Schema Information
#
# Table name: available_coupons
#
#  id                :integer          not null, primary key
#  codeschool_coupon :string(255)
#  peepcode_coupon   :string(255)
#  recipes_coupon    :string(255)
#
# Indexes
#
#  index_available_coupons_on_codeschool_coupon  (codeschool_coupon) UNIQUE
#  index_available_coupons_on_peepcode_coupon    (peepcode_coupon) UNIQUE
#
