require 'spec_helper'

describe AchievementsController do
  describe 'awarding badges' do
    let(:api_key) { "abcd" }

    it 'should award 24pullrequests badges' do
      api_access = Fabricate(:api_access, api_key: api_key, awards: %w(TwentyFourPullRequestsParticipant2012 TwentyFourPullRequestsContinuous2012))
      participant = Fabricate(:user, github: "bashir")
      post :award, badge: 'TwentyFourPullRequestsParticipant2012', date: '12/24/2012', github: participant.github, api_key: api_key
      participant.badges.count.should == 1
      participant.badges.first.is_a? TwentyFourPullRequestsParticipant2012
      post :award, badge: 'TwentyFourPullRequestsContinuous2012', date: '12/24/2012', github: participant.github, api_key: api_key
      participant.badges.count.should == 2
      participant.badges.last.is_a? TwentyFourPullRequestsContinuous2012
    end

    it 'should fail to allow awards with no api key' do
      api_access = Fabricate(:api_access, api_key: api_key, awards: %w(TwentyFourPullRequestsParticipant2012 TwentyFourPullRequestsContinuous2012))
      participant = Fabricate(:user, github: "bashir")
      post :award, badge: 'TwentyFourPullRequestsParticipant2012', date: '12/24/2012', github: participant.github
      participant.badges.count.should == 0
    end

    it 'should fail to allow awards if api_key does not have award privileges for the requested badge' do
      api_access = Fabricate(:api_access, api_key: api_key, awards: %w(TwentyFourPullRequestsParticipant2012 TwentyFourPullRequestsContinuous2012))
      participant = Fabricate(:user, github: "bashir")
      post :award, badge: 'SomeRandomBadge', date: '12/24/2012', github: participant.github, api_key: api_key
      participant.badges.count.should == 0
    end
  end
end