class ResetUserAvatarJob
  include Sidekiq::Worker
  #This job is temporary

  def perform(id)
    user = User.find(id)
    user.avatar.download! user.thumbnail_url
    user.save(validate:false) #some users are invalid for some reason.
  end
end
