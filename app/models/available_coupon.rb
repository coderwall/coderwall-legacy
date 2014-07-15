class AvailableCoupon < ActiveRecord::Base
end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: available_coupons
#
#  id                :integer          not null, primary key
#  codeschool_coupon :string(255)      indexed
#  peepcode_coupon   :string(255)      indexed
#  recipes_coupon    :string(255)
#
# Indexes
#
#  index_available_coupons_on_codeschool_coupon  (codeschool_coupon) UNIQUE
#  index_available_coupons_on_peepcode_coupon    (peepcode_coupon) UNIQUE
#
