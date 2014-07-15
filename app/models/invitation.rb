class Invitation < ActiveRecord::Base
end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: invitations
#
#  id               :integer          not null, primary key
#  email            :string(255)
#  team_document_id :string(255)
#  token            :string(255)
#  state            :string(255)
#  inviter_id       :integer
#  created_at       :datetime
#  updated_at       :datetime
#
