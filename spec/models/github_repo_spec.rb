describe GithubRepo, :pending do
  before :each do
    register_fake_paths

    u = Fabricate(:user)
    u.admin = true
    u.github_token = access_token
    u.save
  end

  def register_fake_paths
    access_token = "9432ed76b16796ec034670524d8176b3f5fee9aa"
    client_id = "974695942065a0e00033"
    client_secret = "7d49c0deb57b5f6c75e6264ca12d20d6a8ffcc68"

    stub_request(:get, "https://api.github.com/repos/mdeiters/semr/languages?client_id=#{client_id}&client_secret=#{client_secret}&per_page=100").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'repo_languages.js')), content_type: 'application/json; charset=utf-8')
    stub_request(:get, "https://api.github.com/repos/mdeiters/semr/forks?client_id=#{client_id}&client_secret=#{client_secret}&per_page=100").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'repo_forks.js')), content_type: 'application/json; charset=utf-8')
    stub_request(:get, "https://api.github.com/repos/mdeiters/semr/contributors?client_id=#{client_id}&client_secret=#{client_secret}&per_page=100&anon=false").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'repo_contributors.js')), content_type: 'application/json; charset=utf-8')
    stub_request(:get, "https://api.github.com/repos/mdeiters/semr/stargazers?client_id=#{client_id}&client_secret=#{client_secret}&per_page=100").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'repo_watchers.js')), content_type: 'application/json; charset=utf-8')
  end

  let(:data) { JSON.parse(File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'user_repo.js'))).with_indifferent_access }
  let(:repo) {
    GithubRepo.for_owner_and_name('mdeiters', 'semr', nil, data)
  }
  let(:access_token) { "9432ed76b16796ec034670524d8176b3f5fee9aa" }
  let(:client_id) { "974695942065a0e00033" }
  let(:client_secret) { "7d49c0deb57b5f6c75e6264ca12d20d6a8ffcc68" }

  describe "contributions" do
    it "should filter the repos the user has contributed to" do
      user = Fabricate(:user)
      org = Fabricate(:github_org)
      profile = Fabricate(:github_profile, github_id: user.github_id, orgs: [org])

      contributed_by_count_repo = Fabricate(:github_repo, owner: {github_id: org.github_id}, contributors: [
          {'github_id' => user.github_id, 'contributions' => 10},
          {'github_id' => nil, 'contributions' => 1000}
      ])

      non_contributed_repo = Fabricate(:github_repo, owner: {github_id: org.github_id}, contributors: [
          {'github_id' => user.github_id, 'contributions' => 5},
          {'github_id' => nil, 'contributions' => 18000}
      ])

      contributed_by_count_repo.significant_contributions?(user.github_id).should == true
      non_contributed_repo.significant_contributions?(user.github_id).should == false
    end
  end

  it 'should have an owner' do
    repo.owner.github_id.should == 7330
    repo.owner.login.should == 'mdeiters'
    repo.owner.gravatar.should == 'aacb7c97f7452b3ff11f67151469e3b0'
  end

  it 'should update repo on second call' do
    data = JSON.parse(File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'user_repo.js'))).with_indifferent_access
    2.times do
      GithubRepo.for_owner_and_name('mdeiters', 'semr', nil, data)
    end
    GithubRepo.count.should == 1
  end

  it 'should indicate dominant language' do
    repo.dominant_language.should == 'Ruby'
  end

  it 'should indicate dominant language percantage' do
    repo.dominant_language_percentage.should == 55
  end

  it 'should indicate if contents' do
    repo.has_contents?.should == true
  end

  it 'should indicate no contents if there are no languages', pending: 'incorrect data' do
    stub_request(:get, "https://api.github.com/repos/mdeiters/semr/languages?client_id=#{client_id}&client_secret=#{client_secret}&per_page=100").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'repo_languages_empty.js')), content_type: 'application/json; charset=utf-8')
    repo.has_contents?.should == false
  end

  it 'should not modify users on refresh' do
    original_follower = repo.followers.first

    refreshed_repo = GithubRepo.for_owner_and_name('mdeiters', 'semr', nil, data)
    refreshed_follower = refreshed_repo.followers.first

    refreshed_follower.login.should == original_follower.login
    refreshed_follower.gravatar.should == original_follower.gravatar
  end

  describe 'tagging' do

    it 'contains tags between refreshes' do
      modified_repo = GithubRepo.find(repo._id)
      modified_repo.add_tag 'a'
      modified_repo.add_tag 'b'
      modified_repo.save!

      refreshed_repo = GithubRepo.for_owner_and_name('mdeiters', 'semr', nil, data)
      refreshed_repo.tags.should include('a', 'b')
    end

    it 'should tag dominant language' do
      repo.tags.should include("Ruby")
    end

    it 'does not duplicate tags on refresh' do
      repo.tags.should == GithubRepo.for_owner_and_name('mdeiters', 'semr', nil, data).tags
    end

    describe 'tags javascript projects' do
      it 'tags jquery if dominant lanugage is js and description to include jquery' do
        stub_request(:get, 'https://github.com/mdeiters/semr/raw/master/README').to_return(body: 'empty')
        stub_request(:get, "https://api.github.com/repos/mdeiters/semr/languages?client_id=#{client_id}&client_secret=#{client_secret}&per_page=100").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'repo_languages_js.js')), content_type: 'application/json; charset=utf-8')

        data[:description] = 'something for jquery'
        repo.tags.should include('Ruby')
      end

      it 'tags node if dominant lanugage is js and description has nodejs in it' do
        pending "Disabled inspecting README because of false positives"
        #FakeWeb.register_uri(:get, 'https://github.com/mdeiters/semr/raw/master/README', body: 'empty')
        #FakeWeb.register_uri(:get, "https://api.github.com/repos/mdeiters/semr/languages?client_id=#{client_id}&client_secret=#{client_secret}&per_page=100", body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'repo_languages_js.js')), content_type: 'application/json; charset=utf-8')

        data[:description] = 'Node Routing'
        repo.tags.should include('Node')
      end

      it 'tags node if dominant lanugage is js and readme has node in it' do
        pending "Disabled inspecting README because of false positives"
        #FakeWeb.register_uri(:get, "https://api.github.com/repos/mdeiters/semr/languages?client_id=#{client_id}&client_secret=#{client_secret}&per_page=100", body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'repo_languages_js.js')), content_type: 'application/json; charset=utf-8')
        #FakeWeb.register_uri(:get, 'https://github.com/mdeiters/semr/raw/master/README', body: 'trying out node')
        repo.tags.should include('Node')
      end
    end
  end

  describe 'viewing readme' do
    it 'finds the readme for .txt files', functional: true do
      repo.readme.should =~ /semr gem uses the oniguruma library/
    end

    it 'should cache readme for repeat calls' do
      #FakeWeb.register_uri(:get, 'https://github.com/mdeiters/semr/raw/master/README', [body: 'test readme'])
      repo.readme.should == repo.readme
    end
  end
end
