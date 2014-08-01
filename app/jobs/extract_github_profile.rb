class ExtractGithubProfile
  include Sidekiq::Worker
  sidekiq_options queue: :low


  def perform(id)
    profile = Users::Github::Profile.find(id)
    client = Octokit::Client.new
    user = client.user(profile.login)
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
  end

end