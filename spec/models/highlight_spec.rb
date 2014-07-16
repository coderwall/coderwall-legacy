require 'spec_helper'

RSpec.describe Highlight, :type => :model do


end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: highlights
#
#  id          :integer          not null, primary key
#  user_id     :integer          indexed
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  featured    :boolean          default(FALSE), indexed
#
# Indexes
#
#  index_highlights_on_featured  (featured)
#  index_highlights_on_user_id   (user_id)
#
