# ActivateUserWorker
# TODO: RefreshUserJob seems to be the blocker, refactor this into sync
# 	codebase that calls async jobs[RefreshUserJob, ?NotifierMailer?]
class ActivateUserWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high

  def perform(user_id, always_activate = true)
    user = User.find(user_id)

    return if user.active? && !always_activate

    RefreshUserJob.new.perform(user.username)

    return if user.badges.empty?

    user.activate!
    NotifierMailer.welcome_email(user.username).deliver
  end
end
