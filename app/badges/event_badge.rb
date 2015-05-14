class EventBadge < BadgeBase
  describe 'Event badge',
           redemption_required: lambda { raise "Not implemented" }

  def award?
    false
  end
end