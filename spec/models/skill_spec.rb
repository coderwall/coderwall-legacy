# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `skills`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`attended_events`**     | `text`             |
# **`created_at`**          | `datetime`         |
# **`deleted`**             | `boolean`          | `default(FALSE), not null`
# **`deleted_at`**          | `datetime`         |
# **`endorsements_count`**  | `integer`          | `default(0)`
# **`id`**                  | `integer`          | `not null, primary key`
# **`name`**                | `string(255)`      | `not null`
# **`repos`**               | `text`             |
# **`speaking_events`**     | `text`             |
# **`tokenized`**           | `string(255)`      |
# **`updated_at`**          | `datetime`         |
# **`user_id`**             | `integer`          |
# **`weight`**              | `integer`          | `default(0)`
#
# ### Indexes
#
# * `index_skills_on_deleted_and_user_id`:
#     * **`deleted`**
#     * **`user_id`**
# * `index_skills_on_user_id`:
#     * **`user_id`**
#

require 'spec_helper'

describe Skill do
  let(:user) { Fabricate(:user) }

  it 'soft deletes a users skill' do
    ruby_skill = user.add_skill('ruby')
    user.skills.should include(ruby_skill)
    ruby_skill.destroy

    user.reload
    user.skills.should_not include(ruby_skill)
    user.skills.with_deleted.should include(ruby_skill)
  end

  it 'downcases and removes ambersands and spaces' do
    Skill.tokenize('Ruby & Rails').should == 'rubyandrails'
  end

  it 'removes spacing from skills' do
    Skill.create!(name: 'ruby ', user: user).name.should == 'ruby'
  end

  it 'tokenizes every skill on creation' do
    Skill.create!(name: 'Ruby ', user: user).tokenized.should == 'ruby'
  end

  it 'does not create duplicate skills differing in only case' do
    Skill.create!(name: 'javascript', user: user).tokenized.should == 'javascript'
    duplicate_skill = Skill.new(name: 'JavaScript', user: user)
    duplicate_skill.should_not be_valid
  end

  it 'increments the owners endorsement count when a skill is endorsed' do
    ruby = user.add_skill('ruby')
    ruby.endorsed_by(endorser = Fabricate(:user))
    ruby.reload
    ruby.endorsements_count.should == 1
    user.reload
    user.endorsements_count.should == 1
  end

  it 'should return the users badges for the skill' do
    user.award(objective_c_badge = Bear.new(user))
    user.award(git_badge = Octopussy.new(user))
    objective_c = user.add_skill(objective_c_badge.skill)
    objective_c.matching_badges_in(user.badges).should have(1).badge
    objective_c.matching_badges_in(user.badges).first.badge_class.should == Bear
  end

  it 'should build repos from facts on creation' do
    ruby_fact = Fabricate(:github_original_fact, context: user)
    skill = user.add_skill('ruby')
    skill.repos.size.should == 1
    skill.repos.first[:name].should == ruby_fact.name
    skill.repos.first[:url].should == ruby_fact.url
  end

  it 'should build speaking events from facts on creation' do
    ruby_fact = Fabricate(:lanyrd_original_fact, context: user)
    skill = user.add_skill('Ruby')
    skill.speaking_events.size.should == 1
    skill.speaking_events.first[:name].should == ruby_fact.name
    skill.speaking_events.first[:url].should == ruby_fact.url
  end

  it 'should build attended events from facts on creation' do
    ruby_fact = Fabricate(:lanyrd_original_fact, context: user, tags: ['lanyrd', 'event', 'attended', 'Software', 'Ruby'])
    skill = user.add_skill('Ruby')
    skill.attended_events.size.should == 1
    skill.attended_events.first[:name].should == ruby_fact.name
    skill.attended_events.first[:url].should == ruby_fact.url
  end

  it 'should not add duplicate skills' do
    skill = user.add_skill('Javascript')
    skill.tokenized.should == "javascript"
    user.add_skill('JavaScript')
    user.skills.count.should == 1
    skill.destroy
    user.reload
    user.add_skill('Javascript')
    user.skills.count.should == 1
  end

  describe 'matching protips' do
    it 'should not be a link' do
      original_protip = Fabricate(:protip, topics: ['Ruby', 'Java'], user: Fabricate(:user))
      link_protip = Fabricate(:link_protip, topics: ['Ruby', 'Java'], user: Fabricate(:user))
      skill = user.add_skill('Ruby')
      matching = skill.matching_protips_in([original_protip, link_protip])
      matching.should include(original_protip)
      matching.should_not include(link_protip)
    end

    it 'should have the same token' do
      ruby_protip = Fabricate(:protip, topics: ['Ruby'], user: Fabricate(:user))
      java_protip = Fabricate(:protip, topics: ['Java'], user: Fabricate(:user))
      ruby_skill = user.add_skill('Ruby')
      matching = ruby_skill.matching_protips_in([ruby_protip, java_protip])
      matching.should include(ruby_protip)
      matching.should_not include(java_protip)
    end
  end
end
