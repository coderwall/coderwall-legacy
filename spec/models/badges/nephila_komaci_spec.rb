require 'spec_helper'

describe NephilaKomaci do
  let(:languages) { {
      "PHP" => 2519686,
      "Python" => 76867
  } }
  let(:repo) { Fabricate(:github_repo, languages: languages) }
  let(:profile) { Fabricate(:github_profile, github_id: repo.owner.github_id) }
  let(:user) { Fabricate(:user, github_id: profile.github_id) }

  before :all do
    Fact.delete_all
  end

  it 'should have a name and description' do
    NephilaKomaci.description.should_not be_blank
  end

  it 'should award php dev with badge' do
    user.build_github_facts

    badge = NephilaKomaci.new(user)
    badge.award?.should == true
    badge.reasons[:links].should_not be_empty
  end

end
