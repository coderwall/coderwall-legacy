require 'spec_helper'

describe Philanthropist do
  it 'should have a name and description' do
    Philanthropist.name.should_not be_blank
    Philanthropist.description.should_not be_blank
  end

  it 'should award user if they have 50 or more original repos with contents' do
    user = Fabricate(:user, github: 'mdeiters')

    50.times do
      Fabricate(:github_original_fact, context: user)
    end

    badge = Philanthropist.new(user.reload)
    badge.award?.should == true
    badge.reasons.should == "for having shared 50 individual projects."
  end

  it 'should not award empty repos' do
    user = Fabricate(:user, github: 'mdeiters')

    49.times do
      Fabricate(:github_original_fact, context: user)
    end

    badge = Philanthropist.new(user.reload)
    badge.award?.should == false
  end

end