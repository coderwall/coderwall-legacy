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
      channels           = Audience.to_channels(audience)
      activity_feed_keys = channels.map { |channel| Audience.channel_to_key(channel) }

      if drip_rate == :immediately
        channels.each do |channel|
          publish_event(channel, data)
        end
      else
        activity_feed_keys.each_with_index do |activity_feed_key, index|
          data.merge!({ channel: channels[index] }.with_indifferent_access)
          score_for_event = Time.now.to_f
          Redis.current.zadd(activity_feed_key, score_for_event.to_f, data)
          count = Redis.current.zcard(activity_feed_key)
          Redis.current.zremrangebyrank(activity_feed_key, 0, count - TABLE_SIZE) if count > TABLE_SIZE
        end
      end
    end

    def publish_event(channel, data)
      data.merge!(timestamp: Time.now.to_i)
      publish(channel, data.to_json)
    end

    def user_activity(user, from, to, limit, publish=false)

      activity_feed_keys = user.nil? ? Audience.to_key(Audience.all).to_a : user.subscribed_channels.map { |channel| Audience.channel_to_key(channel) }
      count              = 0
      from               = from.nil? ? "-inf" : from.to_f
      to                 = to.nil? ? "inf" : to.to_f
      activities         = []

      activity_feed_keys.each do |activity_feed_key|
        i = 1
        Redis.current.zrangebyscore(activity_feed_key, from, to).each do |activity|

          Rails.logger.warn("[EVAL:#{i}] Event#user_activity(user = #{user.inspect}, from = #{from.inspect}, limit = #{limit.inspect}, publish = #{publish.inspect}) set to eval activity = #{activity.inspect}") if ENV['DEBUG']
          i += 1

          break if count == limit
          data    = eval(activity).with_indifferent_access
          channel = data[:channel]
          data.delete(:channel)

          if publish
            publish_event(channel, data)
          else
            activities << data.merge({ timestamp: (data[:event_id] || Time.now.to_i) })
          end
          count += 1
        end
      end
      activities
    end

    def extra_information(data)
      extra_info = {}
      u          = User.find_by_username(data['user']['username']) unless data['user'].nil?
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
