# == Schema Information
#
# Table name: available_coupons
#
#  id                :integer          not null, primary key
#  codeschool_coupon :string(255)
#  peepcode_coupon   :string(255)
#  recipes_coupon    :string(255)
#

class AvailableCoupon < ActiveRecord::Base
end
