class AwardUserJob
  include Sidekiq::Worker

  sidekiq_options queue: :user

  def perform(username, badges)
    user = User.with_username(username)

    if badges.first.is_a?(String)
      badges.map!(&:constantize)
    end

    user.check_achievements!(badges)
  end

end
