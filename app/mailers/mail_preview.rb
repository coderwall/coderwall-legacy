class MailPreview < MailView
  USERNAME = 'just3ws'

  def popular_protips
    from = 60.days.ago
    to = 0.days.ago
    user = User.with_username(USERNAME)
    protips = ProtipMailer::Queries.popular_protips(from, to)
    ProtipMailer.popular_protips(user, protips, from, to).deliver
  end

  def old_weekly_digest
    WeeklyDigestMailer.weekly_digest(USERNAME)
  end
end
