class EventBadge < BadgeBase
  describe 'Event badge',
           redemption_required: lambda { fail 'Not implemented' }

  def award?
    false
  end
end
