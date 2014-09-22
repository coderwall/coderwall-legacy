require 'spec_helper'

RSpec.describe MembersController, :type => :controller do
  let(:current_user) { Fabricate(:user) }
  let(:invitee) { Fabricate(:user) }
  let(:team) { Fabricate(:team) }
  before { controller.send :sign_in, current_user }

  describe "DELETE #destroy" do
    it "should remove the team member from the current users team" do
      member_added = team.add_member(invitee)
      team.add_member(current_user)

      controller.send(:current_user).reload
      delete :destroy, team_id: team.id, id: member_added.id

      expect(team.reload).not_to have_member(invitee)
      expect(response).to redirect_to(teamname_url(slug: current_user.team.slug))
    end

    it 'redirects back to leader board when you remove yourself' do
      member = team.add_member(current_user)
      controller.send(:current_user).reload
      delete :destroy, team_id: team.id, id: member.id
      expect(response).to redirect_to(teams_url)
    end
  end
end
