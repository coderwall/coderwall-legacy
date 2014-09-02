class ProtipMailerPopularProtipsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform(from, to)
    protips = ProtipMailer::Queries.popular_protips(from, to)

    User.find_each(batch_size: 100) do |user|
      ProtipMailer.popular_protips(user, protips, from, to).deliver
    end
  end
end
