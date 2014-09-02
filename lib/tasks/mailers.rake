namespace :mailers do
  task popular_protips: :environment do
    from = 60.days.ago
    to = 0.days.ago
    user = User.with_username('mcansky')
    protips = ProtipMailer::Queries.popular_protips(from, to)
    ProtipMailer.popular_protips(user, protips, from, to).deliver
  end
end
