class AvailableCoupon < ActiveRecord::Base
end

# == Schema Information
# Schema version: 20140728205954
#
# Table name: available_coupons
#
#  id                :integer          not null, primary key
#  codeschool_coupon :string(255)
#  peepcode_coupon   :string(255)
#  recipes_coupon    :string(255)
#
