class AwardUserJob
  include Sidekiq::Worker

  sidekiq_options queue: :low

  def perform(username, badges)
    user = User.find_by_username(username)

    if badges.first.is_a?(String)
      badges.map!(&:constantize)
    end

    user.check_achievements!(badges)
  end

end