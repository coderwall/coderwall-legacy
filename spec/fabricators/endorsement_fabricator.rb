Fabricator(:endorsement) do
  endorsed(fabricator: :user)
  endorser(fabricator: :user)
  skill(fabricator: :skill)
end

# == Schema Information
# Schema version: 20140918031936
#
# Table name: endorsements
#
#  id                :integer          not null, primary key
#  endorsed_user_id  :integer
#  endorsing_user_id :integer
#  specialty         :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  skill_id          :integer
#
