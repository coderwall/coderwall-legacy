require 'spec_helper'

RSpec.describe NephilaKomaci, type: :model do
  let(:user) { Fabricate(:user, github: 'codebender') }

  before :all do
    Fact.delete_all
  end

  it 'should have a name and description' do
    expect(NephilaKomaci.description).not_to be_blank
  end

  it 'should award the badge if the user has a original PHP dominent repo' do
    fact = Fabricate(:github_original_fact, context: user,
      tags: %w(PHP repo original personal github))

    badge = NephilaKomaci.new(user)
    expect(badge.award?).to eq(true)
    expect(badge.reasons[:links]).not_to be_empty
  end

end
