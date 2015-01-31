require 'spec_helper'

RSpec.describe Velociraptor, type: :model do
  let(:user) { Fabricate(:user, github: 'codebender') }

  it 'should have a name and description' do
    expect(Velociraptor.description).not_to be_blank
  end

  it 'should award perl dev with badge' do
    fact = Fabricate(:github_original_fact, context: user,
      tags: %w(Perl repo original personal github))

    badge = Velociraptor.new(user)
    expect(badge.award?).to eq(true)
    expect(badge.reasons[:links]).not_to be_empty
  end
end
