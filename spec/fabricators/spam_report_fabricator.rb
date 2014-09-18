Fabricator(:spam_report) do
end

# == Schema Information
# Schema version: 20140918031936
#
# Table name: spam_reports
#
#  id             :integer          not null, primary key
#  spammable_id   :integer          not null
#  spammable_type :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
