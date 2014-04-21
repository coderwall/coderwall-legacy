class BadgeJustification < ActiveRecord::Base
  belongs_to :badge
  validates_uniqueness_of :description, scope: :badge_id
end
