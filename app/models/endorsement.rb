class Endorsement < ActiveRecord::Base
  belongs_to :endorsed, class_name: User.name, foreign_key: :endorsed_user_id, counter_cache: :endorsements_count, touch: true
  belongs_to :endorser, class_name: User.name, foreign_key: :endorsing_user_id
  belongs_to :skill, counter_cache: :endorsements_count, touch: :updated_at

  validates_presence_of :skill_id
  validates_presence_of :endorser
  validates_presence_of :endorsed
  after_create :generate_event

  def generate_event
    GenerateEventJob.perform_async(self.event_type, Audience.user(self.endorsed.id), self.to_event_hash, 1.minute)
  end

  def to_event_hash
    { endorsement: { endorsed: self.endorsed.name, endorser: self.endorser.name, skill: self.skill.name },
      user:        { username: self.endorser.username } }
  end

  def event_type
    :endorsement
  end
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
