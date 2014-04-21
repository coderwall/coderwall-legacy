class TeamMembersController < ApplicationController

  def destroy
    @user = User.find(params[:id])
    return head(:forbidden) unless signed_in? && (team.admin?(current_user) || current_user == @user)
    team.remove_user(@user)
    record_event("removed team") if !Team.where(id: team.id.to_s).exists?

    if @user == current_user
      flash[:notice] = "Ok, we've removed you from #{team.name}."
      record_event("removed themselves from team")
      return redirect_to(teams_url)
    else
      record_event("removed user from team")
      respond_to do |format|
        format.js {}
        format.html { redirect_to(teamname_url(slug: team.slug)) }
      end
    end
  end

  private
  def team
    @team ||= Team.find(params[:team_id])
  end

  def is_email_address?(value)
    m = Mail::Address.new(value)
    r = m.domain && m.address == value
    t = m.__send__(:tree)
    r &&= (t.domain.dot_atom_text.elements.size > 1)
  end
end