class AdminController < BaseAdminController

  def index
  end

  def cache_stats
    @cache_stats = Rails.cache.stats
  end

  def failed_jobs
    @page     = params[:page].try(:to_i) || 1
    @per_page = params[:per_page].try(:to_i) || 10

    @total_failed = Delayed::Job.
      where("last_error IS NOT NULL").
      count

    @jobs = Delayed::Job.
      where("last_error IS NOT NULL").
      offset((@page - 1) * @per_page).
      limit(@per_page).
      order("updated_at DESC")
  end

  if Rails.env.development?
    skip_before_filter :require_admin!, only: [:index, :toggle_premium_team]

    def toggle_premium_team
      team         = current_user.team || begin
        team = Team.first
        team.add_user(current_user)
      end
      team.premium = !team.premium
      team.save!
      return redirect_to('/')
    end

  end

  def teams

  end

  def sections_teams
    @teams = Team.completed_at_least(params[:num_sections].to_i)
  end

  def section_teams
    @teams = Team.with_completed_section(parse_section_name(params[:section]))
  end

  def parse_section_name(section_name)
    name = Team::SECTIONS.select { |section| section == section_name }.first
    return name.to_sym unless name.nil?
  end
end
