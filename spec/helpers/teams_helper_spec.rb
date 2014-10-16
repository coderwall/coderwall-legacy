require 'spec_helper'

RSpec.describe TeamsHelper, :type => :helper do
  describe "#exact_team_exists?" do
    let(:teams) { Fabricate.build_times(3, :team) }

    it "returns true if there is a team with exact matching name" do
      teams << Fabricate.build(:team, name: 'test_name', slug: 'test-name')
      expect(helper.exact_team_exists?(teams, 'test-name')).to be_truthy
    end

    it "returns false if there is no team with exact mathcing name" do
      expect(helper.exact_team_exists?(teams, 'non-existent team name')).to be_falsey
    end


  end
end
