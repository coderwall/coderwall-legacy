require 'vcr_helper'

RSpec.describe User, type: :model, vcr: true do

  let(:user) { Fabricate(:user) }
  it 'should respond to methods' do
    expect(user).to respond_to :build_facts
    expect(user).to respond_to :build_speakerdeck_facts
    expect(user).to respond_to :build_slideshare_facts
    expect(user).to respond_to :build_lanyrd_facts
    expect(user).to respond_to :build_bitbucket_facts
    expect(user).to respond_to :build_github_facts
    expect(user).to respond_to :build_linkedin_facts
    expect(user).to respond_to :repo_facts
    expect(user).to respond_to :lanyrd_facts
    expect(user).to respond_to :times_spoken
    expect(user).to respond_to :times_attended
    expect(user).to respond_to :add_skills_for_unbadgified_facts
    expect(user).to respond_to :add_skills_for_repo_facts!
    expect(user).to respond_to :add_skills_for_lanyrd_facts!
  end


end