module UserEventConcern
  extend ActiveSupport::Concern

  def subscribed_channels
    Audience.to_channels(Audience.user(self.id))
  end

  def generate_event(options={})
    event_type = self.event_type(options)
    GenerateEventJob.perform_async(event_type, event_audience(event_type, options), self.to_event_hash(options), 30.seconds)
  end

  def event_audience(event_type, options={})
    if event_type == :profile_view
      Audience.user(self.id)
    elsif event_type == :followed_team
      Audience.team(options[:team].try(:id))
    end
  end

  def to_event_hash(options={})
    event_hash = { user: { username: options[:viewer] || self.username } }
    if options[:viewer]
      event_hash[:views] = total_views
    elsif options[:team]
      event_hash[:follow] = { followed: options[:team].try(:name), follower: self.try(:name) }
    end
    event_hash
  end

  def event_type(options={})
    if options[:team]
      :followed_team
    else
      :profile_view
    end
  end
end

