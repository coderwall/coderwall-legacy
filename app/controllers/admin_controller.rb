class AdminController < BaseAdminController

  def index
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
