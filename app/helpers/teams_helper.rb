module TeamsHelper
  def badge_display_limit
    7
  end

  def percentile(team)
    @last_percentile ||= 100
    percentile = Percentile.for(team.score).to_i
    if percentile != 0 && percentile <= @last_percentile - 3
      @last_percentile = percentile
      return "<div class='percentile'>#{@last_percentile.ordinalize} percentile</div>".html_safe
    end
  end

  def following_team_text(team)
    if current_user.following_team?(team)
      'Stop Following'
    else
      'Follow'
    end
  end

  def following_team_class(team)
    if current_user.following_team?(team)
      'unfollow'
    else
      'follow'
    end
  end

  def on_leaderboard?
    params[:action] == 'index'
  end

  def top_teams_css_class
    on_leaderboard? ? 'active' : ''
  end

  def followed_teams_css_class
    current_page?(action: :followed) ? 'active' : ''
  end

  def followed_teams_button_css_class(team)
    (signed_in? and current_user.following?(team)) ? 'btn-primary disabled' : ''
  end

  def followed_teams_button_text(team)
    (signed_in? and current_user.following?(team)) ? 'Following' : 'Follow'
  end

  def followed_teams_hash
    (signed_in? ? current_user.teams_being_followed.reduce(Hash.new(0)) { |h, team| h.merge(team.id => true) } : {})
  end

  def build_your_team_path
    if signed_in?
      new_team_path
    else
      signup_path
    end
  end

  def edit_your_team_text
    'Build your team'
  end

  def viewing_my_team_while_unauthenticated?
    !signed_in? && viewing_user && viewing_user.belongs_to_team?(@team)
  end

  def viewing_my_team?
    signed_in? && (current_user.belongs_to_team?(@team) || current_user.admin?)
  end

  def team_invite_link_for(user)
    user.team
    invite
  end

  def invite_to_team_url(team = @team)
    invitation_url(team.id, r: CGI.escape(current_user.referral_token))
  end

  def invite_to_team_message(team)
    "Click the link below to join #{team.name} on Coderwall:\n#{invite_to_team_url(team)}"
  end

  def display_locations?
    false # !@team.locations.empty?
  end

  def display_protips?
    @team.has_protips?
  end

  def show_team_score?
    @team.size >= 3 && @team.rank > 0
  end

  def friendly_team_path(team)
    teamname_path(slug: team.slug)
  end

  def teams_leaderboard_title(teams)
    'Top tech teams in the world | ' + teams.first(3).map(&:name).join(', ') + ' and many more!'
  end

  def leaderboard_css_class
    return 'active' if params[:controller] == 'teams' && params[:action] == 'leaderboard'
  end

  def featured_teams_css_class
    return 'active' if params[:controller] == 'teams' && params[:action] == 'index'
  end

  def message_to_create_ehanced_team
    if signed_in? && !current_user.team.nil?
      "Is #{current_user.team.name} awesome and hiring? Enhance your team's profile here. Hiring teams are visited by 7X more developers" unless current_user.team.try(:hiring?) == true
    else
      "Have an amazing team that is hiring? Setup your team's profile."
    end
  end

  def no_account_no_team?
    !signed_in?
  end

  def member_no_team?
    signed_in? && current_user.team.nil?
  end

  def add_job_path(team)
    (team.has_specified_enough_info? || @team.can_post_job?) ? new_team_opportunity_path(team) : '#not-enough-sections-completed'
  end

  def add_job_class
    (@team.has_specified_enough_info? || @team.can_post_job?) ? 'enable' : 'disable'
  end

  def banner_image_or_default(team)
    unless team.featured_banner_image.blank?
      team.featured_banner_image
    else
      !team.big_image.blank? ? team.big_image : default_featured_banner
    end
  end

  def default_featured_banner
    'premium-teams/team-default.jpg'
  end

  def team_job_path(team)
    teamname_path(slug: team.slug) + '#open-positions'
  end

  def edit_team_locations_path(team)
    teamname_path(slug: team.slug) + '/edit/#locations'
  end

  def change_resume_path
    settings_path(anchor: 'jobs')
  end

  def exact_team_exists?(teams, team)
    teams.map { |team| Team.slugify(team.name) }.include? team.slug
  end
end
