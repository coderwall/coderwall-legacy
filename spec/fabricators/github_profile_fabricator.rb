Fabricator(:github_profile) do
  name { Faker::Name.name }
  login { 'mdeiters' }
  _id { 7330 }
  type { GithubProfile::ORGANIZATION }
end

Fabricator(:owner, from: :github_user) do
  _id { 7330 }
  login { 'mdeiters' }
  gravatar { 'aacb7c97f7452b3ff11f67151469e3b0' }
end

Fabricator(:follower, from: :github_user) do
  github_id { sequence(:github_id) }
  login { sequence(:login) { |i| "user#{i}" } }
  gravatar { 'aacb7c97f7452b3ff11f67151469e3b0' }
end

Fabricator(:watcher, from: :github_user) do
  github_id { 1 }
  login { 'mojombo' }
  gravatar { '25c7c18223fb42a4c6ae1c8db6f50f9b' }
end

Fabricator(:github_repo) do
  after_build { |repo| repo.forks = 1 }
  name { sequence(:repo) { |i| "repo#{i}" } }
  owner { Fabricate.attributes_for(:owner) }
  html_url { 'https://github.com/mdeiters/semr' }
  languages do {
    'Ruby' => 111_435,
    'JavaScript' => 50_164
  } end
end

Fabricator(:github_org, class_name: 'GithubProfile') do
  name { Faker::Company.name }
  login { 'coderwall' }
  _id { 1234 }
  type { GithubProfile::ORGANIZATION }
end
