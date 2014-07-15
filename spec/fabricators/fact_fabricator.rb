Fabricator(:fact, from: 'fact') do
  context { Fabricate(:user) }
end

Fabricator(:lanyrd_original_fact, from: :fact) do
  owner { |fact| fact[:context].lanyrd_identity }
  url { Faker::Internet.domain_name }
  identity { |fact| "/#{rand(1000)}/speakerconf/:" + fact[:owner] }
  name { Faker::Company.catch_phrase }
  relevant_on { rand(100).days.ago }
  tags { ['lanyrd', 'event', 'spoke', 'Software', 'Ruby'] }
end

Fabricator(:github_original_fact, from: :fact) do
  owner { |fact| fact[:context].github_identity }
  url { Faker::Internet.domain_name }
  identity { |fact| fact[:url] + ':' + fact[:owner] }
  name { Faker::Company.catch_phrase }
  relevant_on { rand(100).days.ago }
  metadata { {
      language: 'Ruby',
      languages: ["Python", "Shell"],
      times_forked: 0,
      watchers: ['pjhyat', 'frank']
  } }
  tags { ['Ruby', 'repo', 'original', 'personal', 'github'] }
end

Fabricator(:github_fork_fact, from: :github_original_fact) do
  tags { ['repo', 'github', 'fork', 'personal'] }
end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: facts
#
#  id          :integer          not null, primary key
#  identity    :string(255)      indexed
#  owner       :string(255)      indexed
#  name        :string(255)
#  url         :string(255)
#  tags        :text
#  metadata    :text
#  relevant_on :datetime
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_facts_on_identity  (identity)
#  index_facts_on_owner     (owner)
#
