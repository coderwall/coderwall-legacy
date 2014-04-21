class Event < Struct.new(:data)
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  extend Publisher

  class << self

    VERSION    = 1
    TABLE_SIZE = 50

    def generate_event(event_type, audience, data={}, drip_rate=:immediately)
      data.merge!({ event_type: event_type }.with_indifferent_access)
      data = { version: VERSION, event_id: Time.now.utc.to_i }.with_indifferent_access.merge(data)
      data.deep_merge!(extra_information(data))
      drip_rate = :immediately if drip_rate.nil?
      send_admin_notifications(event_type, data, audience[:admin]) if audience.has_key? :admin
      channels           = Audience.to_channels(audience)
      activity_feed_keys = channels.map { |channel| Audience.channel_to_key(channel) }

      if drip_rate == :immediately
        #Rails.logger.debug("data=#{data.class.name},#{data.inspect}, #{extra_information(data)}, #{data[:user].inspect}, #{drip_rate}")
        channels.each do |channel|
          publish_event(channel, data)
        end
      else
        activity_feed_keys.each_with_index do |activity_feed_key, index|
          data.merge!({ channel: channels[index] }.with_indifferent_access)
          #Rails.logger.debug("data=#{data.class.name},#{data.inspect}, #{extra_information(data)}, #{data[:user].inspect}, #{drip_rate}")
          #last_event = REDIS.LINDEX(user.activity_feed_key, 0).collect{|event| Event.new(event)}.first
          score_for_event = Time.now.to_f
          REDIS.zadd(activity_feed_key, score_for_event.to_f, data)
          count = REDIS.zcard(activity_feed_key)
          REDIS.zremrangebyrank(activity_feed_key, 0, count - TABLE_SIZE) if count > TABLE_SIZE
        end
      end
    end

    def score_based_on_drip_rate(activity_feed_key, event_type, drip_rate)
      time_difference_requested    = drip_rate_to_time(drip_rate)
      last_similar_event_timestamp = last_similar_event_timestamp(activity_feed_key, event_type)
      score_for_event              = last_similar_event_timestamp.to_f + time_difference_requested.to_f
      score_for_event
    end

    def send_admin_notifications(event_type, data, queue)
      unless queue.nil?
        if event_type.to_sym == :new_protip
          protip = Protip.with_public_id(data[:public_id])

          ProcessingQueue.enqueue(protip, queue) unless protip.nil?
        end
      end
    end

    def publish_event(channel, data)
      #puts data.inspect
      data.merge!(timestamp: Time.now.to_i)

      #puts "publish event #{data[:event_type]}"

      publish(channel, data.to_json)
    end

    def drip_rate_to_time(drip_rate)
      case drip_rate
        when :immediately
          Time.now
        when :hourly
          1.hour
        when :daily
          1.day
        when :weekly
          1.week
        when :monthly
          1.month
        else
          drip_rate
      end
    end

    def last_similar_event_timestamp(activity_feed_key, event_type)
      # we basically look at every event in the future (if any) and find the last event of same event type so we can space it from that. Otherwise, we
      # just space it from now. it is not perfect because we miss the corner case that similar event was in the past but limits the searches.

      Hash[*REDIS.zrangebyscore(activity_feed_key, Time.now.to_f, "inf", withscores: true)].sort_by { |k, v| v }.reverse.each do |activity, score|
        if eval(activity)[:event_type] == event_type
          return score
        end
      end
      REDIS.zrange(activity_feed_key, 0, 0, withscores: true)[1] || Time.now.to_i
    end

    def user_activity(user, from, to, limit, publish=false)

      activity_feed_keys = user.nil? ? Audience.to_key(Audience.all).to_a : user.subscribed_channels.map { |channel| Audience.channel_to_key(channel) }
      count              = 0
      from               = from.nil? ? "-inf" : from.to_f
      to                 = to.nil? ? "inf" : to.to_f
      activities         = []

      activity_feed_keys.each do |activity_feed_key|
        #puts "activity_feed_key=#{activity_feed_key}, #{from}, #{to}, #{count}, #{limit}, #{publish}"
        REDIS.zrangebyscore(activity_feed_key, from, to).each do |activity|
          break if count == limit
          #puts "PUBLISHING #{activity}"
          data    = eval(activity).with_indifferent_access
          channel = data[:channel]
          data.delete(:channel)

          if publish
            publish_event(channel, data) if publish
          else
            activities << data.merge({ timestamp: (data[:event_id] || Time.now.to_i) })
          end
          #REDIS.zrem(activity_feed_key, activity)
          count += 1
        end
      end
      activities
    end

    def extra_information(data)
      extra_info = {}
      u          = User.with_username(data['user']['username']) unless data['user'].nil?
      extra_info.merge!(user_info(u)) unless u.nil?
      extra_info.merge!(team_info(u.team)) unless u.nil? or u.team.nil?
      extra_info.with_indifferent_access
    end

    def user_info(user)
      { user: {
        username:     user.username,
        profile_url:  user.profile_url,
        profile_path: Rails.application.routes.url_helpers.badge_path(user.username),
      } }
    end

    def team_info(team)
      { team: { name:        team.name,
                avatar:      ActionController::Base.helpers.asset_path(team.try(:avatar_url)),
                url:         Rails.application.routes.url_helpers.teamname_path(team.slug),
                follow_path: Rails.application.routes.url_helpers.follow_team_path(team),
                skills:      team.specialties_with_counts.map { |skills| skills[0] }.first(2),
                hiring:      team.hiring?
      } }
    end
  end
end