Fabricator(:skill) do
  name { 'Ruby' }
end

# == Schema Information
# Schema version: 20140918031936
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
