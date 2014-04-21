require 'spec_helper'

describe Velociraptor do
  let(:languages) { {
      "C" => 194738,
      "C++" => 105902,
      "Perl" => 2519686
  } }
  let(:repo) { Fabricate(:github_repo, languages: languages) }
  let(:profile) { Fabricate(:github_profile, github_id: repo.owner.github_id) }
  let(:user) { Fabricate(:user, github_id: profile.github_id) }

  it 'should have a name and description' do
    Velociraptor.description.should_not be_blank
  end

  it 'should award perl dev with badge' do
    user.build_github_facts

    badge = Velociraptor.new(user)
    badge.award?.should == true
    badge.reasons[:links].should_not be_empty
  end
end
