namespace :weekly do
  namespace :digest do
    task :send => :environment do
      send_digest_to_all(ENV['WEEKLY_DIGEST_AUDIENCE'] || 'all')
    end

    task :automatic => :environment do
      now_in_pst = Time.now.in_time_zone("Pacific Time (US & Canada)")
      if now_in_pst.tuesday? && now_in_pst.hour >= 10
        send_digest_to_all(ENV['WEEKLY_DIGEST_AUDIENCE'] || 'all')
      end
    end

    def send_digest_to_all(audience)
      users = User.receives_digest.no_emails_since(5.days.ago).order('last_request_at asc').select([:username, :id])
      if audience == "2weeks"
        users = users.where('last_request_at < ?', 2.weeks.ago)
      elsif audience == "1month"
        users = users.where('last_request_at < ?', 1.month.ago)
      end
      users.find_each(:batch_size => 1000) do |user|
        WeeklyDigestMailer.weekly_digest(user.username).deliver
      end
    end
  end
end