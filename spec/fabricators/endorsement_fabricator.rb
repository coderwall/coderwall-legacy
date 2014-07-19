Fabricator(:endorsement) do
  endorsed(fabricator: :user)
  endorser(fabricator: :user)
  skill(fabricator: :skill)
end

# == Schema Information
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
# Indexes
#
#  index_endorsements_on_endorsed_user_id   (endorsed_user_id)
#  index_endorsements_on_endorsing_user_id  (endorsing_user_id)
#  only_unique_endorsements                 (endorsed_user_id,endorsing_user_id,specialty) UNIQUE
#
