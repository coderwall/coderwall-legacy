class SentMail < ActiveRecord::Base
  belongs_to :mailable, polymorphic: true
  belongs_to :user

  alias_attribute :receiver, :user
end

# == Schema Information
# Schema version: 20140728214411
#
# Table name: sent_mails
#
#  id            :integer          not null, primary key
#  mailable_id   :integer
#  mailable_type :string(255)
#  user_id       :integer
#  sent_at       :datetime
#
