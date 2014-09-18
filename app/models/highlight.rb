class Highlight < ActiveRecord::Base
  belongs_to :user

  after_create :add_to_timeline

  def self.random(limit = 1)
    order("Random()").limit(limit)
  end

  def self.random_featured(limit = 1)
    where(featured: true).order("Random()").limit(limit).all(include: :user)
  end

  def event
    @event || nil
  end

  private
  def add_to_timeline
    @event = Event.create_highlight_event(self.user, self)
  end
end

# == Schema Information
# Schema version: 20140918031936
#
# Table name: highlights
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  featured    :boolean          default(FALSE)
#
