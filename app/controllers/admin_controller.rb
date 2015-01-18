class AdminController < BaseAdminController

  def index
    @networks = Network.where('protips_count_cache > 0').order('protips_count_cache desc')
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
    section_name.to_sym if Team::SECTIONS.include? section_name
  end
end
