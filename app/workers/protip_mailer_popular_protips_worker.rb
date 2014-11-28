class ProtipMailerPopularProtipsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :mailer

  def perform(from, to)

    # In development the arguments are the correct type but in production
    # they have to be recast from string back to date types :D
    from = Time.zone.parse(from.to_s)
    to = Time.zone.parse(to.to_s)

    protip_ids = ProtipMailer::Queries.popular_protips(from, to).map(&:id)

    fail "Only #{protip_ids.count} protips but expected 10" unless protip_ids.count == 10

    User.receives_digest.order('updated_at desc').find_each(batch_size: 100) do |user|
      ProtipMailerPopularProtipsSendWorker.perform_async(user.id, protip_ids, from, to)
    end
  end
end
