require 'spec_helper'

describe Altruist do

  it 'should have a name and description' do
    Altruist.description.should include('20')
  end

  it 'should award user if they have 50 or more original repos with contents' do
    user = Fabricate(:user, github: 'mdeiters')

    20.times do
      Fabricate(:github_original_fact, context: user)
    end

    badge = Altruist.new(user.reload)
    badge.award?.should == true
    badge.reasons.should == "for having shared 20 individual projects."
  end

  it 'should not award empty repos' do
    user = Fabricate(:user, github: 'mdeiters')

    19.times do
      Fabricate(:github_original_fact, context: user)
    end

    badge = Altruist.new(user.reload)
    badge.award?.should == false
  end
end