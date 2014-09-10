require 'vcr_helper'

describe Coderwall::Github::Queries do

  let(:coderwall_user) { Fabricate(:user) }
  let(:client) { Coderwall::Github::Client.new(coderwall_user.github_token).client }
  let(:github_username) { 'just3ws' }

  describe Coderwall::Github::Queries::ProfileFor do
    subject { Coderwall::Github::Queries::ProfileFor.new(client, github_username) }
    let(:user) {
      VCR.use_cassette('fetch github user for just3ws') do
        subject.fetch
      end
    }

    it 'sets the client reader' do
      expect(subject.client).to_not be_nil
    end

    it 'inherits from Queries::Base' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Base)
    end

    it 'inherits from Queries::BaseWithGithubUsername' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::BaseWithGithubUsername)
    end

    it 'returns a hash' do
      expect(user).to be_a_kind_of(Hash)
    end

    it 'filters the user attribute' do
      Coderwall::Github::Queries::ProfileFor.exclude_attributes do |exclude_attribute|
        expect(user.has_key?(exclude_attribute)).to be false
      end
    end
  end

  describe Coderwall::Github::Queries::FollowersFor do
    subject { Coderwall::Github::Queries::FollowersFor.new(client, github_username) }

    let(:followers) {
      VCR.use_cassette('fetch github followers for just3ws') do
        subject.fetch
      end
    }

    it 'fetchs the github followers for just3ws' do
      expect(followers.select { |repo| repo[:login] == 'coderwall-admin' }).to_not be_nil
    end

    it 'returns a hash' do
      expect(followers).to be_a_kind_of(Array)
      expect(followers.first).to be_a_kind_of(Hash)
    end
  end

  describe Coderwall::Github::Queries::FollowingFor do
    subject { Coderwall::Github::Queries::FollowingFor.new(client, github_username) }
    let(:following) {
      VCR.use_cassette('fetch github just3ws following') do
        subject.fetch
      end
    }

    it 'fetchs the github just3ws following' do
      expect(following.select { |repo| repo[:full_name] == 'assemblymade/coderwall' }).to_not be_nil
    end

    it 'returns a hash' do
      expect(following).to be_a_kind_of(Array)
      expect(following.first).to be_a_kind_of(Hash)
    end
  end

  describe Coderwall::Github::Queries::WatchedReposFor do
    subject { Coderwall::Github::Queries::WatchedReposFor.new(client, github_username) }

    let(:watched_repos) {
      VCR.use_cassette('fetch just3ws watched repos') do
        subject.fetch
      end
    }

    it 'fetchs repos that just3ws is watching' do
      expect(watched_repos.select { |repo| repo[:full_name] == 'assemblymade/coderwall' }).to_not be_nil
    end

    it 'returns a hash' do
      expect(watched_repos).to be_a_kind_of(Array)
      expect(watched_repos.first).to be_a_kind_of(Hash)
    end

    it 'filters the repo attribute' do
      Coderwall::Github::Queries::WatchedReposFor.exclude_attributes do |exclude_attribute|
        expect(watched_repos.first.has_key?(exclude_attribute)).to be false
      end
    end
  end

  describe Coderwall::Github::Queries::ReposFor do
    subject { Coderwall::Github::Queries::ReposFor.new(client, github_username) }

    let(:repos) {
      VCR.use_cassette('fetch just3ws repos') do
        subject.fetch
      end
    }

    it 'fetchs just3ws repos' do
      expect(repos.select { |repo| repo[:full_name] == 'assemblymade/coderwall' }).to_not be_nil
    end

    it 'returns a hash' do
      expect(repos).to be_a_kind_of(Array)
      expect(repos.first).to be_a_kind_of(Hash)
    end

    it 'filters the repo attribute' do
      Coderwall::Github::Queries::ReposFor.exclude_attributes do |exclude_attribute|
        expect(repos.first.has_key?(exclude_attribute)).to be false
      end
    end
  end

  describe Coderwall::Github::Queries::RepoFor do
    let(:repo_name) { 'coderwall' }

    subject { Coderwall::Github::Queries::RepoFor.new(client, github_username, repo_name) }

    let(:repo) {
      VCR.use_cassette('fetch just3ws/coderwall repos') do
        subject.fetch
      end
    }

    it 'inherits from Queries::Base' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Base)
    end

    it 'inherits from Queries::BaseWithGithubUsernameAndRepoName' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::BaseWithGithubUsernameAndRepoName)
    end

    it 'fetchs just3ws coderwall repo' do
      expect(repo[:full_name]).to be == 'just3ws/coderwall'
    end

    it 'returns a hash' do
      expect(repo).to be_a_kind_of(Hash)
    end
  end
end
