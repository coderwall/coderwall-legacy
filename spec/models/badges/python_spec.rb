require 'spec_helper'

describe Python do
  let(:languages) { {
      "Python" => 2519686,
      "Java" => 76867
  } }
  let(:repo) { Fabricate(:github_repo, languages: languages) }
  let(:profile) { Fabricate(:github_profile, github_id: repo.owner.github_id) }
  let(:user) { Fabricate(:user, github_id: profile.github_id) }

  it 'should have a name and description' do
    Python.description.should_not be_blank
  end

  it 'should not award ruby dev with one ruby repo' do
    user.build_github_facts

    badge = Python.new(user)
    badge.award?.should == true
    badge.reasons[:links].should_not be_empty
  end

  it 'should not for a python dev' do
    languages.delete('Python')
    user.build_github_facts

    badge = Python.new(user)
    badge.award?.should == false
  end
end
