Fabricator(:endorsement) do
  endorsed(fabricator: :user)
  endorser(fabricator: :user)
  skill(fabricator: :skill)
end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: endorsements
#
#  id                :integer          not null, primary key
#  endorsed_user_id  :integer          indexed, indexed => [endorsing_user_id, specialty]
#  endorsing_user_id :integer          indexed, indexed => [endorsed_user_id, specialty]
#  specialty         :string(255)      indexed => [endorsed_user_id, endorsing_user_id]
#  created_at        :datetime
#  updated_at        :datetime
#  skill_id          :integer
#
# Indexes
#
#  index_endorsements_on_endorsed_user_id   (endorsed_user_id)
#  index_endorsements_on_endorsing_user_id  (endorsing_user_id)
#  only_unique_endorsements                 (endorsed_user_id,endorsing_user_id,specialty) UNIQUE
#
