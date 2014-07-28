class Picture < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  mount_uploader :file, PictureUploader

  belongs_to :user
end

# == Schema Information
# Schema version: 20140728214411
#
# Table name: pictures
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  file       :string(255)
#  created_at :datetime
#  updated_at :datetime
#
