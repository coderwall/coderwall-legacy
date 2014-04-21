require 'spec_helper'

describe TeamMembersController do
  let(:current_user) { Fabricate(:user) }
  let(:invitee) { Fabricate(:user) }
  let(:team) { Fabricate(:team) }
  before { controller.send :sign_in, current_user }

  describe "DELETE #destroy" do
    it "should remove the team member from the current users team" do
      member_added = team.add_user(invitee)
      team.add_user(current_user)

      controller.send(:current_user).reload
      delete :destroy, team_id: team.id, id: member_added.id

      team.reload.should_not have_member(invitee)
      response.should redirect_to(teamname_url(slug: current_user.team.slug))
    end

    it 'redirects back to leader board when you remove yourself' do
      member = team.add_user(current_user)
      controller.send(:current_user).reload
      delete :destroy, team_id: team.id, id: member.id
      response.should redirect_to(teams_url)
    end
  end
end