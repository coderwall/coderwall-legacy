require 'spec_helper'

RSpec.describe Highlight, :type => :model do


end

# == Schema Information
# Schema version: 20140728214411
#
# Table name: highlights
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  featured    :boolean          default(FALSE)
#
