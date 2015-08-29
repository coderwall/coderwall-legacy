class MembersController < ApplicationController
  before_action :set_team

  # DELETE                /teams/:team_id/members/:id(.:format)
  def destroy
    self_removal = current_user.id == params[:id]
    return head(:forbidden) unless signed_in? && (@team.admin?(current_user) || self_removal)
    @team.members.find_by_user_id!(params[:id]).destroy

    if self_removal
      flash[:notice] = "Ok, You have left : #{@team.name}."
      record_event("removed themselves from team")
      redirect_to(teams_url)
    else
      record_event("removed user from team")
      respond_to do |format|
        format.js {}
        format.html { redirect_to(teamname_url(slug: @team.slug)) }
      end
    end
  end

  private

  def set_team
    @team = Team.find(params[:team_id])
  end
end
