require 'spec_helper'

describe Mongoose do
  let(:languages) { {
      "Ruby" => 2519686,
      "JavaScript" => 6107,
      "Python" => 76867
  } }
  let(:repo) { Fabricate(:github_repo, languages: languages) }
  let(:profile) { Fabricate(:github_profile, github_id: repo.owner.github_id) }
  let(:user) { Fabricate(:user, github_id: profile.github_id) }

  before :all do
    Fact.delete_all
  end

  it 'should have a name and description' do
    Mongoose.description.should_not be_blank
  end

  it 'should award ruby dev with one ruby repo' do
    user.build_github_facts

    badge = Mongoose.new(user)
    badge.award?.should == true
    badge.reasons[:links].should_not be_empty
  end

  it 'should not for a python dev' do
    languages.delete('Ruby')
    user.build_github_facts

    badge = Mongoose.new(user)
    badge.award?.should == false
  end
end
