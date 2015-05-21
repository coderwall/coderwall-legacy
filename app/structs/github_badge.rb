# TODO: Refactor API Calls to Sidekiq Workers
# TODO: Verify that GITHUB_ADMIN_USER is required, and can't be replaced with app based auth
# TODO: Refactor/Reflow Error Handling, Don't rescue fail. Defer to sidekiq job auto retry
class GithubBadge
  def initialize
    @client = Octokit::Client.new(
      login: ENV['GITHUB_ADMIN_USER'],
      password: ENV['GITHUB_ADMIN_USER_PASSWORD'],
      client_id: ENV['GITHUB_CLIENT_ID'],
      client_secret: ENV['GITHUB_SECRET']
    )
  rescue Exception => e
  end

  def add(badge, github_username)
    badge_name = get_name badge

    id = @client.organization_teams("coderwall-#{badge_name}")[1].id

    @client.add_team_membership(id, github_username)
  rescue Octokit::NotFound => e
    Rails.logger.error("Failed to add badge #{badge_name} for #{github_username}") if ENV['DEBUG']
  rescue Errno::ECONNREFUSED => e
    retry
  end

  def remove(badge, github_username)
    badge_name = get_name badge
    id         = @client.organization_teams("coderwall-#{badge_name}")[1].id
    @client.remove_team_member(id, github_username)
  rescue Octokit::NotFound => e
    Rails.logger.error("Failed to remove badge #{badge_name} for #{github_username}") if ENV['DEBUG']
  rescue Errno::ECONNREFUSED => e
    retry
  end

  def add_all(badges, github_username)
    badges.map { |b| add(b, github_username) }
  end

  def remove_all(badges, github_username)
    badges.map { |b| remove(b, github_username) }
  end

  def get_name(badge)
    name = badge.badge_class.to_s
    # GH caps size of org name, so have to shorten special cases
    if name =~ /TwentyFourPullRequestsContinuous/
      return "24PullRequestsContinuous"
    elsif name =~ /TwentyFourPullRequestsParticipant/
      return "24PullRequestsParticipant"
    end
    name
  end
end
