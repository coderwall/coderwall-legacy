module UserStatistics
  extend ActiveSupport::Concern

  #OPTIMIZE
  module ClassMethods
    def signups_by_day
      find_by_sql("SELECT to_char(created_at, 'MM DD') AS day, count(*) AS signups from users group by to_char(created_at, 'MM DD') order by to_char(created_at, 'MM DD')").collect { |u| [u.day, u.signups] }
    end

    def signups_by_hour
      find_by_sql("SELECT to_char(created_at, 'HH24') AS hour, count(*) AS signups from users where created_at > NOW() - interval '24 hours' group by to_char(created_at, 'HH24') order by to_char(created_at, 'HH24')").collect { |u| [u.hour, u.signups] }
    end

    def signups_by_month
      find_by_sql("SELECT to_char(created_at, 'MON') AS day, count(*) AS signups from users group by to_char(created_at, 'MON') order by to_char(created_at, 'MON') DESC").collect { |u| [u.day, u.signups] }
    end

    def repeat_visits_by_count
      find_by_sql("SELECT login_count, count(*) AS visits from users group by login_count").collect { |u| [u.login_count, u.visits] }
    end

    def monthly_growth
      prior = where("created_at < ?", 31.days.ago).count
      month = where("created_at >= ?", 31.days.ago).count
      ((month.to_f / prior.to_f) * 100)
    end

    def weekly_growth
      prior = where("created_at < ?", 7.days.ago).count
      week  = where("created_at >= ?", 7.days.ago).count
      ((week.to_f / prior.to_f) * 100)
    end

    def most_active_by_country(since=1.week.ago)
      select('country, count(distinct(id))').where('last_request_at > ?', since).group(:country).order('count(distinct(id)) DESC')
    end
  end
end