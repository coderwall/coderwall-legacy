class ExtractGithubProfile
  include Sidekiq::Worker
  sidekiq_options queue: :github


  def perform(id)
    client = Octokit::Client.new
    if  ENV['TRAVIS'].blank? && client.ratelimit[:remaining] < 1000
      # If we have less than 1000 request remaining, delay this job
      # We leaving 1000 for more critical tasks
      retry_at = client.ratelimit[:resets_at] + rand(id)
      ExtractGithubProfile.perform_at(retry_at, id)
      return
    end
    profile = Users::Github::Profile.find(id)
    begin
      user = client.user(profile.github_id)
      #TODO Rails4
      profile.update_attributes(
          {
              name: user.name,
              hireable: user.hireable,
              company: user.company,
              location: user.location,
              github_id: user.id,
              github_created_at: user.created_at,
              github_updated_at: user.updated_at,
              spider_updated_at: Time.now
          }
      )
    rescue Octokit::NotFound
      #TODO add spec for invalid login
      #user don't exist in github: remove all reference to it.
      profile.destroy
      profile.user.clear_github!
    rescue ActiveRecord::RecordNotFound
      #Profile don't exist : do nothing and mark as done
      true
    end
  end

end
