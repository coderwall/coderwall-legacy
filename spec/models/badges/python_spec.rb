require 'spec_helper'

RSpec.describe Python, type: :model do
  let(:user) { Fabricate(:user, github: 'codebender') }

  it 'should have a name and description' do
    expect(Python.description).not_to be_blank
  end

  it 'awards the user if the user has a Python dominent repo' do
    fact = Fabricate(:github_original_fact, context: user,
      tags: %w(Python repo original personal github))

    badge = Python.new(user)
    expect(badge.award?).to eq(true)
    expect(badge.reasons[:links]).not_to be_empty
  end

  it 'does not award the user if the user has no Python dominent repo' do
    fact = Fabricate(:github_original_fact, context: user,
      tags: %w(Ruby repo original personal github))

    badge = Python.new(user)
    expect(badge.award?).to eq(false)
  end
end
