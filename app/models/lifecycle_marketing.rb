class LifecycleMarketing
  class << self

    # run with: rake marketing:emails:send
    def process!
      send_activity_updates
      send_reminders_to_create_skill
      send_reminders_to_create_team
      send_reminders_to_create_protip
      send_reminders_to_invite_team_members
      send_reminders_to_link_accounts
    end

    def send_reminders_to_create_team
      Rails.logger.info "Skipping team create reminder. Got more hate than love"
    end

    def send_reminders_to_invite_team_members
      key = 'email:team-reminders:teams-emailed'
      Redis.current.del(key)
      valid_activity_users.where("team_id IS NOT NULL").where(remind_to_invite_team_members: nil).find_each do |user|
        unless Redis.current.sismember(key, user.team_id) or Team.find(user.team_id).created_at < 1.week.ago
          Redis.current.sadd key, user.team_id
          NotifierMailer.remind_to_invite_team_members(user.username).deliver
        end
      end
    end

    def send_activity_updates
      send_new_achievement_reminders
    end

    def send_reminders_to_create_protip
      Rails.logger.info "Skipping :send_reminders_to_create_protip until implemented"
    end

    def send_reminders_to_create_skill
      Rails.logger.info "Skipping :send_reminders_to_create_skill until implemented"
    end

    def send_reminders_to_link_accounts
      Rails.logger.info "Skipping :send_reminders_to_link_accounts until implemented"
    end

    def send_new_achievement_reminders
      User.where(id: valid_activity_users.joins("inner join badges on badges.user_id = users.id").where("badges.created_at > users.last_request_at").reorder('badges.created_at ASC').select(:id)).select('DISTINCT(username), id').find_each do |user|
        NotifierMailer.new_badge(user.username).deliver
      end
    end

    def valid_newsletter_users
      User.active.no_emails_since(1.week.ago).receives_newsletter
    end

    def valid_activity_users
      User.active.no_emails_since(3.days.ago).receives_activity
    end
  end
end
