require 'vcr_helper'

RSpec.describe GithubRepo,  type: :model, skip: ENV['TRAVIS']  do
  before :each do
    register_fake_paths

    u = Fabricate(:user)
    u.admin = true
    u.github_token = access_token
    u.save
  end

  def register_fake_paths
    access_token = '9432ed76b16796ec034670524d8176b3f5fee9aa'
    client_id = '974695942065a0e00033'
    client_secret = '7d49c0deb57b5f6c75e6264ca12d20d6a8ffcc68'

    stub_request(:get, "https://api.github.com/repos/mdeiters/semr/languages?client_id=#{client_id}&client_secret=#{client_secret}&per_page=100").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'repo_languages.js')), content_type: 'application/json; charset=utf-8')
    stub_request(:get, "https://api.github.com/repos/mdeiters/semr/forks?client_id=#{client_id}&client_secret=#{client_secret}&per_page=100").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'repo_forks.js')), content_type: 'application/json; charset=utf-8')
    stub_request(:get, "https://api.github.com/repos/mdeiters/semr/contributors?client_id=#{client_id}&client_secret=#{client_secret}&per_page=100&anon=false").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'repo_contributors.js')), content_type: 'application/json; charset=utf-8')
    stub_request(:get, "https://api.github.com/repos/mdeiters/semr/stargazers?client_id=#{client_id}&client_secret=#{client_secret}&per_page=100").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'repo_watchers.js')), content_type: 'application/json; charset=utf-8')
  end

  let(:data) { JSON.parse(File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'user_repo.js'))).with_indifferent_access }
  let(:repo) do
    GithubRepo.for_owner_and_name('mdeiters', 'semr', nil, data)
  end
  let(:access_token) { '9432ed76b16796ec034670524d8176b3f5fee9aa' }
  let(:client_id) { '974695942065a0e00033' }
  let(:client_secret) { '7d49c0deb57b5f6c75e6264ca12d20d6a8ffcc68' }

  describe 'contributions' do
    it 'should filter the repos the user has contributed to' do
      user = Fabricate(:user)
      org = Fabricate(:github_org)
      profile = Fabricate(:github_profile, github_id: user.github_id, orgs: [org])

      contributed_by_count_repo = Fabricate(:github_repo, owner: { github_id: org.github_id }, contributors: [
        { 'github_id' => user.github_id, 'contributions' => 10 },
        { 'github_id' => nil, 'contributions' => 1000 }
      ])

      non_contributed_repo = Fabricate(:github_repo, owner: { github_id: org.github_id }, contributors: [
        { 'github_id' => user.github_id, 'contributions' => 5 },
        { 'github_id' => nil, 'contributions' => 18_000 }
      ])

      expect(contributed_by_count_repo.significant_contributions?(user.github_id)).to eq(true)
      expect(non_contributed_repo.significant_contributions?(user.github_id)).to eq(false)
    end
  end

  it 'should have an owner' do
    expect(repo.owner.github_id).to eq(7330)
    expect(repo.owner.login).to eq('mdeiters')
    expect(repo.owner.gravatar).to eq('aacb7c97f7452b3ff11f67151469e3b0')
  end

  it 'should update repo on second call' do
    data = JSON.parse(File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'user_repo.js'))).with_indifferent_access
    2.times do
      GithubRepo.for_owner_and_name('mdeiters', 'semr', nil, data)
    end
    expect(GithubRepo.count).to eq(1)
  end

  it 'should indicate dominant language' do
    expect(repo.dominant_language).to eq('Ruby')
  end

  it 'should indicate dominant language percantage' do
    expect(repo.dominant_language_percentage).to eq(55)
  end

  it 'should indicate if contents' do
    expect(repo.has_contents?).to eq(true)
  end

  it 'should indicate no contents if there are no languages', skip: 'incorrect data' do
    stub_request(:get, "https://api.github.com/repos/mdeiters/semr/languages?client_id=#{client_id}&client_secret=#{client_secret}&per_page=100").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'repo_languages_empty.js')), content_type: 'application/json; charset=utf-8')
    expect(repo.has_contents?).to eq(false)
  end

  it 'should not modify users on refresh' do
    original_follower = repo.followers.first

    refreshed_repo = GithubRepo.for_owner_and_name('mdeiters', 'semr', nil, data)
    refreshed_follower = refreshed_repo.followers.first

    expect(refreshed_follower.login).to eq(original_follower.login)
    expect(refreshed_follower.gravatar).to eq(original_follower.gravatar)
  end

  describe 'tagging' do

    it 'contains tags between refreshes' do
      modified_repo = GithubRepo.find(repo._id)
      modified_repo.add_tag 'a'
      modified_repo.add_tag 'b'
      modified_repo.save!

      refreshed_repo = GithubRepo.for_owner_and_name('mdeiters', 'semr', nil, data)
      expect(refreshed_repo.tags).to include('a', 'b')
    end

    it 'should tag dominant language' do
      expect(repo.tags).to include('Ruby')
    end

    it 'does not duplicate tags on refresh' do
      expect(repo.tags).to eq(GithubRepo.for_owner_and_name('mdeiters', 'semr', nil, data).tags)
    end

    describe 'tags javascript projects' do
      it 'tags jquery if dominant lanugage is js and description to include jquery' do
        stub_request(:get, 'https://github.com/mdeiters/semr/raw/master/README').to_return(body: 'empty')
        stub_request(:get, "https://api.github.com/repos/mdeiters/semr/languages?client_id=#{client_id}&client_secret=#{client_secret}&per_page=100").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'repo_languages_js.js')), content_type: 'application/json; charset=utf-8')

        data[:description] = 'something for jquery'
        expect(repo.tags).to include('Ruby')
      end

      it 'tags node if dominant lanugage is js and description has nodejs in it' do
        skip 'Disabled inspecting README because of false positives'
        # FakeWeb.register_uri(:get, 'https://github.com/mdeiters/semr/raw/master/README', body: 'empty')
        # FakeWeb.register_uri(:get, "https://api.github.com/repos/mdeiters/semr/languages?client_id=#{client_id}&client_secret=#{client_secret}&per_page=100", body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'repo_languages_js.js')), content_type: 'application/json; charset=utf-8')

        data[:description] = 'Node Routing'
        expect(repo.tags).to include('Node')
      end

      it 'tags node if dominant lanugage is js and readme has node in it' do
        skip 'Disabled inspecting README because of false positives'
        # FakeWeb.register_uri(:get, "https://api.github.com/repos/mdeiters/semr/languages?client_id=#{client_id}&client_secret=#{client_secret}&per_page=100", body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'repo_languages_js.js')), content_type: 'application/json; charset=utf-8')
        # FakeWeb.register_uri(:get, 'https://github.com/mdeiters/semr/raw/master/README', body: 'trying out node')
        expect(repo.tags).to include('Node')
      end
    end
  end

  describe 'viewing readme' do
    it 'finds the readme for .txt files', functional: true do
      expect(repo.readme).to match(/semr gem uses the oniguruma library/)
    end

    it 'should cache readme for repeat calls' do
      # FakeWeb.register_uri(:get, 'https://github.com/mdeiters/semr/raw/master/README', [body: 'test readme'])
      expect(repo.readme).to eq(repo.readme)
    end
  end
end
