class ProtipMailerPopularProtipsSendWorker
  include Sidekiq::Worker
  sidekiq_options queue: :mailer

  def perform(user_id, protip_ids, from, to)
    fail "Only #{protip_ids.count} protips but expected 10" unless protip_ids.count == 10

    begin
      if REDIS.sismember(ProtipMailer::CAMPAIGN_ID, user_id.to_s)
        Rails.logger.warn("Already sent email to #{user_id} please check Redis SET #{ProtipMailer::CAMPAIGN_ID}.")
      else
        Rails.logger.warn("Sending email to #{user_id}.")
        # In development the arguments are the correct type but in production
        # they have to be recast from string back to date types :D
        from = Time.zone.parse(from.to_s)
        to = Time.zone.parse(to.to_s)
        user = User.find(user_id.to_i)
        protips = Protip.where('id in (?)', protip_ids.map(&:to_i) )
        fail "Only #{protips.count} protips but expected 10" unless protips.count == 10

        ProtipMailer.popular_protips(user, protips, from, to).deliver
      end
    rescue => ex
      Rails.logger.error("[ProtipMailer.popular_protips] Unable to send email due to '#{ex}' >>\n#{ex.backtrace.join("\n  ")}")
      Rails.logger.ap([from, to, user_id, protip_ids], :error)
    end
  end
end
