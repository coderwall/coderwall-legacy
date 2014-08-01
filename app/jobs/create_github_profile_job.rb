#TODO DELETE ME

class CreateGithubProfileJob
  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform
    User.where('github is not null').find_each  do |user|
      user.create_github_profile if user.github_profile.blank?
    end
  end
end