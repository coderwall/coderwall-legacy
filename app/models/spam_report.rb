class SpamReport < ActiveRecord::Base
  belongs_to :spammable, polymorphic: true
end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: spam_reports
#
#  id             :integer          not null, primary key
#  spammable_id   :integer          not null
#  spammable_type :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
