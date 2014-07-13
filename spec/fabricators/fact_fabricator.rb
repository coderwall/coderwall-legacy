# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `facts`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`created_at`**   | `datetime`         |
# **`id`**           | `integer`          | `not null, primary key`
# **`identity`**     | `string(255)`      |
# **`metadata`**     | `text`             |
# **`name`**         | `string(255)`      |
# **`owner`**        | `string(255)`      |
# **`relevant_on`**  | `datetime`         |
# **`tags`**         | `text`             |
# **`updated_at`**   | `datetime`         |
# **`url`**          | `string(255)`      |
#
# ### Indexes
#
# * `index_facts_on_identity`:
#     * **`identity`**
# * `index_facts_on_owner`:
#     * **`owner`**
#

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
