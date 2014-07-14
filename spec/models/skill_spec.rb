# == Schema Information
#
# Table name: skills
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  name               :string(255)      not null
#  endorsements_count :integer          default(0)
#  created_at         :datetime
#  updated_at         :datetime
#  tokenized          :string(255)
#  weight             :integer          default(0)
#  repos              :text
#  speaking_events    :text
#  attended_events    :text
#  deleted            :boolean          default(FALSE), not null
#  deleted_at         :datetime
#
# Indexes
#
#  index_skills_on_deleted_and_user_id  (deleted,user_id)
#  index_skills_on_user_id              (user_id)
#

require 'vcr_helper'

RSpec.describe Skill, :type => :model do
  let(:user) { Fabricate(:user) }

  it 'soft deletes a users skill' do
    ruby_skill = user.add_skill('ruby')
    expect(user.skills).to include(ruby_skill)
    ruby_skill.destroy

    user.reload
    expect(user.skills).not_to include(ruby_skill)
    expect(user.skills.with_deleted).to include(ruby_skill)
  end

  it 'downcases and removes ambersands and spaces' do
    expect(Skill.tokenize('Ruby & Rails')).to eq('rubyandrails')
  end

  it 'removes spacing from skills' do
    expect(Skill.create!(name: 'ruby ', user: user).name).to eq('ruby')
  end

  it 'tokenizes every skill on creation' do
    expect(Skill.create!(name: 'Ruby ', user: user).tokenized).to eq('ruby')
  end

  it 'does not create duplicate skills differing in only case' do
    expect(Skill.create!(name: 'javascript', user: user).tokenized).to eq('javascript')
    duplicate_skill = Skill.new(name: 'JavaScript', user: user)
    expect(duplicate_skill).not_to be_valid
  end

  it 'increments the owners endorsement count when a skill is endorsed' do
    ruby = user.add_skill('ruby')
    ruby.endorsed_by(endorser = Fabricate(:user))
    ruby.reload
    expect(ruby.endorsements_count).to eq(1)
    user.reload
    expect(user.endorsements_count).to eq(1)
  end

  it 'should return the users badges for the skill' do
    user.award(objective_c_badge = Bear.new(user))
    user.award(git_badge = Octopussy.new(user))
    objective_c = user.add_skill(objective_c_badge.skill)
    expect(objective_c.matching_badges_in(user.badges).size).to eq(1)
    expect(objective_c.matching_badges_in(user.badges).first.badge_class).to eq(Bear)
  end

  it 'should build repos from facts on creation' do
    ruby_fact = Fabricate(:github_original_fact, context: user)
    skill = user.add_skill('ruby')
    expect(skill.repos.size).to eq(1)
    expect(skill.repos.first[:name]).to eq(ruby_fact.name)
    expect(skill.repos.first[:url]).to eq(ruby_fact.url)
  end

  it 'should build speaking events from facts on creation' do
    ruby_fact = Fabricate(:lanyrd_original_fact, context: user)
    skill = user.add_skill('Ruby')
    expect(skill.speaking_events.size).to eq(1)
    expect(skill.speaking_events.first[:name]).to eq(ruby_fact.name)
    expect(skill.speaking_events.first[:url]).to eq(ruby_fact.url)
  end

  it 'should build attended events from facts on creation' do
    ruby_fact = Fabricate(:lanyrd_original_fact, context: user, tags: ['lanyrd', 'event', 'attended', 'Software', 'Ruby'])
    skill = user.add_skill('Ruby')
    expect(skill.attended_events.size).to eq(1)
    expect(skill.attended_events.first[:name]).to eq(ruby_fact.name)
    expect(skill.attended_events.first[:url]).to eq(ruby_fact.url)
  end

  it 'should not add duplicate skills' do
    skill = user.add_skill('Javascript')
    expect(skill.tokenized).to eq("javascript")
    user.add_skill('JavaScript')
    expect(user.skills.count).to eq(1)
    skill.destroy
    user.reload
    user.add_skill('Javascript')
    expect(user.skills.count).to eq(1)
  end

  describe 'matching protips' do
    it 'should not be a link' do
      original_protip = Fabricate(:protip, topics: ['Ruby', 'Java'], user: Fabricate(:user))
      link_protip = Fabricate(:link_protip, topics: ['Ruby', 'Java'], user: Fabricate(:user))
      skill = user.add_skill('Ruby')
      matching = skill.matching_protips_in([original_protip, link_protip])
      expect(matching).to include(original_protip)
      expect(matching).not_to include(link_protip)
    end

    it 'should have the same token' do
      ruby_protip = Fabricate(:protip, topics: ['Ruby'], user: Fabricate(:user))
      java_protip = Fabricate(:protip, topics: ['Java'], user: Fabricate(:user))
      ruby_skill = user.add_skill('Ruby')
      matching = ruby_skill.matching_protips_in([ruby_protip, java_protip])
      expect(matching).to include(ruby_protip)
      expect(matching).not_to include(java_protip)
    end
  end
end
