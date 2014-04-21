class Audience
  class << self
    def all
      { all: nil }
    end

    def user(user_id)
      { user: user_id }
    end

    def users(user_ids)
      { users: user_ids }
    end

    def team(team_id)
      { team: team_id }
    end

    def following_user(user_id)
      { user_followers: user_id }
    end

    def following_team(team_id)
      { team_followers: team_id }
    end

    def network(network_id)
      { network: network_id }
    end

    def networks(network_ids)
      { networks: network_ids }
    end

    def team_reach(team_id)
      { team_reach: team_id }
    end

    def user_reach(user_id)
      { user_reach: user_id }
    end

    def admin(queue = nil)
      { admin: queue }
    end

    def to_channels(audience)
      audiences = expand(audience)
      audiences.map { |a| to_channel(a) }
    end

    def to_key(audience)
      to_channels(audience).map { |channel| channel_to_key(channel) }
    end

    def channel_to_key(channel)
      "activityfeed:#{channel}"
    end

    def expand(audience)
      audience.keys.map(&:to_sym).collect do |target|
        if target == :user_reach
          user = User.find(audience[target])
          expand_reach(user) unless user.nil?
        elsif target == :team_reach
          team = Team.find(audience[target])
          expand_reach(team) unless team.nil?
        elsif target == :admin
          User.admins.map do |admin|
            admin.id
          end
        elsif target == :team
          team = Team.find(audience[target])
          team.team_members.map do |team_member|
            team_member.id
          end unless team.nil?
        elsif target == :user_followers
          user = User.find(audience[target])
          expand_followers(user) unless user.nil?
        elsif target == :team_followers
          team = Team.find(audience[target])
          expand_followers(team) unless team.nil?
        elsif target == :all
          expand_all_users
        elsif target == :network
          network = Network.find(audience[target])
          expand_network(network) unless network.nil?
        elsif target == :networks
          networks = Network.where(id: audience[target])
          expand_networks(networks)
        else
          audience[target]
        end
      end.flatten.compact.uniq.map { |user_id| Audience.user(user_id) }
    end

    private
    def expand_followers(user_or_team)
      user_or_team.followers.map do |follower|
        follower.id
      end
    end

    def expand_all_users
      ActiveRecord::Base.connection.select_values(User.select(:id).to_sql)
    end

    def expand_network(network)
      ActiveRecord::Base.connection.select_values(network.members.select(:id).to_sql)
    end

    def expand_networks(networks)
      ActiveRecord::Base.connection.select_values(Follow.where(followable_id: networks.map(&:id)).where(followable_type: Network.name).select(:follower_id).to_sql)
    end

    def expand_reach(user_or_team)
      audiences = []
      audiences.concat(expand_followers(user_or_team))

      if user_or_team.is_a?(Team)
        team = Team.find(user_or_team)
        team.team_members.each do |team_member|
          audiences.concat(expand_followers(team_member))
        end unless team.nil?
      else
        team = User.find(user_or_team).try(:team)
        audiences.concat(expand_followers(team)) unless team.nil?
      end
      audiences
    end

    def to_channel(audience)
      channel_name = Rails.env + ":" + audience.map { |k, v| "#{k}:#{v}" }.first
      #obfiscate for production
      (Rails.env.development? or Rails.env.test?) ? channel_name : Digest::MD5.hexdigest(channel_name)
    end
  end
end