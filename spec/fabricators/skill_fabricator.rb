# == Schema Information
#
# Table name: skills
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  name               :string(255)      not null
#  endorsements_count :integer          default(0)
#  created_at         :datetime
#  updated_at         :datetime
#  tokenized          :string(255)
#  weight             :integer          default(0)
#  repos              :text
#  speaking_events    :text
#  attended_events    :text
#  deleted            :boolean          default(FALSE), not null
#  deleted_at         :datetime
#
# Indexes
#
#  index_skills_on_deleted_and_user_id  (deleted,user_id)
#  index_skills_on_user_id              (user_id)
#

Fabricator(:skill) do
  name { 'Ruby' }
end
