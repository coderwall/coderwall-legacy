class ProtipMailerPopularProtipsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform(from, to)

    # In development the arguments are the correct type but in production
    # they have to be recast from string back to date types :D
    from = Time.zone.parse(from.to_s)
    to = Time.zone.parse(to.to_s)

    protips = ProtipMailer::Queries.popular_protips(from, to)

    User.find_each(batch_size: 100) do |user|
      begin
        if REDIS.sismember(ProtipMailer::CAMPAIGN_ID, user.id.to_s)
          Rails.logger.warn("Already sent email to #{user.id} please check Redis SET #{ProtipMailer::CAMPAIGN_ID}.")
        else
          Rails.logger.warn("Sending email to #{user.id}.")
          ProtipMailer.popular_protips(user, protips, from, to).deliver
        end
      rescue => ex
        Rails.logger.error("[ProtipMailer.popular_protips] Unable to send email due to '#{ex}' >>\n#{ex.backtrace.join("\n  ")}")
        Rails.logger.ap([from, to, user, protips], :error)
      end
    end
  end
end
