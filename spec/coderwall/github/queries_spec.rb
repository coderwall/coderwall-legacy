require 'vcr_helper'

describe Coderwall::Github::Queries do

  let(:coderwall_user) { Fabricate(:user) }
  let(:client) { Coderwall::Github::Client.new(coderwall_user.github_token).client }
  let(:github_username) { 'just3ws' }

  describe Coderwall::Github::Queries::GithubUser::ProfileFor do
    subject { Coderwall::Github::Queries::GithubUser::ProfileFor.new(client, github_username) }
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

    it 'inherits from Queries::GithubUser::Base' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::GithubUser::Base)
    end

    it 'returns a hash' do
      expect(user).to be_a_kind_of(Hash)
    end

    it 'filters the user attribute' do
      Coderwall::Github::Queries::GithubUser::ProfileFor.exclude_attributes do |exclude_attribute|
        expect(user.has_key?(exclude_attribute)).to be false
      end
    end
  end

  describe Coderwall::Github::Queries::GithubUser::FollowersFor do
    subject { Coderwall::Github::Queries::GithubUser::FollowersFor.new(client, github_username) }

    let(:followers) {
      VCR.use_cassette('fetch github followers for just3ws') do
        subject.fetch
      end
    }

    it 'fetchs the github followers for just3ws' do
      expect(followers.select { |repo| repo[:login] == 'coderwall-admin' }).to_not be_nil
    end

    it 'returns an array of hashes' do
      expect(followers).to be_a_kind_of(Array)
      expect(followers.first).to be_a_kind_of(Hash)
    end
  end

  describe Coderwall::Github::Queries::GithubUser::FollowingFor do
    subject { Coderwall::Github::Queries::GithubUser::FollowingFor.new(client, github_username) }
    let(:following) {
      VCR.use_cassette('fetch github just3ws following') do
        subject.fetch
      end
    }

    it 'fetchs the github just3ws following' do
      expect(following.select { |repo| repo[:full_name] == 'assemblymade/coderwall' }).to_not be_nil
    end

    it 'returns an array of hashes' do
      expect(following).to be_a_kind_of(Array)
      expect(following.first).to be_a_kind_of(Hash)
    end
  end

  describe Coderwall::Github::Queries::GithubUser::WatchedReposFor do
    subject { Coderwall::Github::Queries::GithubUser::WatchedReposFor.new(client, github_username) }

    let(:watched_repos) {
      VCR.use_cassette('fetch just3ws watched repos') do
        subject.fetch
      end
    }

    it 'fetchs repos that just3ws is watching' do
      expect(watched_repos.select { |repo| repo[:full_name] == 'assemblymade/coderwall' }).to_not be_nil
    end

    it 'returns an array of hashes' do
      expect(watched_repos).to be_a_kind_of(Array)
      expect(watched_repos.first).to be_a_kind_of(Hash)
    end

    it 'filters the repo attribute' do
      Coderwall::Github::Queries::GithubUser::WatchedReposFor.exclude_attributes do |exclude_attribute|
        expect(watched_repos.first.has_key?(exclude_attribute)).to be false
      end
    end
  end

  describe Coderwall::Github::Queries::GithubUser::ReposFor do
    subject { Coderwall::Github::Queries::GithubUser::ReposFor.new(client, github_username) }

    let(:repos) {
      VCR.use_cassette('fetch just3ws repos') do
        subject.fetch
      end
    }

    it 'fetchs just3ws repos' do
      expect(repos.select { |repo| repo[:full_name] == 'assemblymade/coderwall' }).to_not be_nil
    end

    it 'returns an array of hashes' do
      expect(repos).to be_a_kind_of(Array)
      expect(repos.first).to be_a_kind_of(Hash)
    end

    it 'filters the repo attribute' do
      Coderwall::Github::Queries::GithubUser::ReposFor.exclude_attributes do |exclude_attribute|
        expect(repos.first.has_key?(exclude_attribute)).to be false
      end
    end
  end

  describe Coderwall::Github::Queries::Repo::RepoFor do
    let(:repo_name) { 'coderwall' }

    subject { Coderwall::Github::Queries::Repo::RepoFor.new(client, github_username, repo_name) }

    let(:repo) {
      VCR.use_cassette('fetch just3ws/coderwall repos') do
        subject.fetch
      end
    }

    it 'inherits from Queries::Base' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Base)
    end

    it 'inherits from Queries::Repo::Base' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Repo::Base)
    end

    it 'fetchs just3ws coderwall repo' do
      expect(repo[:full_name]).to be == 'just3ws/coderwall'
    end

    it 'returns a hash' do
      expect(repo).to be_a_kind_of(Hash)
    end
  end

  describe Coderwall::Github::Queries::Repo::LanguagesFor do
    let(:repo_name) { 'coderwall' }

    subject { Coderwall::Github::Queries::Repo::LanguagesFor.new(client, github_username, repo_name) }

    let(:repo_languages) {
      VCR.use_cassette('fetch just3ws/coderwall repo languages') do
        subject.fetch
      end
    }

    it 'inherits from Queries::Base' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Base)
    end

    it 'inherits from Queries::Repo::Base' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Repo::Base)
    end

    it 'fetchs just3ws coderwall repo languages' do
      expect(repo_languages).to have_key(:Ruby)
    end

    it 'returns a hash' do
      expect(repo_languages).to be_a_kind_of(Hash)
    end
  end

  describe Coderwall::Github::Queries::Repo::WatchersFor do
    let(:github_username) { 'assemblymade' }
    let(:repo_name) { 'coderwall' }

    subject { Coderwall::Github::Queries::Repo::WatchersFor.new(client, github_username, repo_name) }

    let(:repo_watchers) {
      VCR.use_cassette('fetch assemblymade/coderwall repo watchers') do
        subject.fetch
      end
    }

    it 'inherits from Queries::Base' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Base)
    end

    it 'inherits from Queries::Repo::Base' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Repo::Base)
    end

    it 'fetchs just3ws coderwall repo watchers' do
      expect(repo_watchers.first).to have_key(:login)
      expect(repo_watchers.first.keys.count).to eq(1)
    end

    it 'returns an array of hashes' do
      expect(repo_watchers).to be_a_kind_of(Array)
      expect(repo_watchers.first).to be_a_kind_of(Hash)
    end
  end

  describe Coderwall::Github::Queries::Repo::ContributorsFor do
    let(:github_username) { 'assemblymade' }
    let(:repo_name) { 'coderwall' }

    subject { Coderwall::Github::Queries::Repo::ContributorsFor.new(client, github_username, repo_name) }

    let(:repo_contributors) {
      VCR.use_cassette('fetch assemblymade/coderwall repo contributors') do
        subject.fetch
      end
    }

    it 'inherits from Queries::Base' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Base)
    end

    it 'inherits from Queries::Repo::Base' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Repo::Base)
    end

    it 'fetchs just3ws coderwall repo contributors' do
      expect(repo_contributors.first).to have_key(:login)
      expect(repo_contributors.first.keys.count).to eq(18)
    end

    it 'returns an array of hashes' do
      expect(repo_contributors).to be_a_kind_of(Array)
      expect(repo_contributors.first).to be_a_kind_of(Hash)
    end
  end

  describe Coderwall::Github::Queries::Repo::CollaboratorsFor do
    let(:github_username) { 'assemblymade' }
    let(:repo_name) { 'coderwall' }

    subject { Coderwall::Github::Queries::Repo::CollaboratorsFor.new(client, github_username, repo_name) }

    let(:repo_collaborators) {
      VCR.use_cassette('fetch assemblymade/coderwall repo collaborators') do
        subject.fetch
      end
    }

    it 'inherits from Queries::Base' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Base)
    end

    it 'inherits from Queries::Repo::Base' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Repo::Base)
    end

    it 'fetchs just3ws coderwall repo collaborators' do
      expect(repo_collaborators.first).to have_key(:login)
      expect(repo_collaborators.first.keys.count).to eq(17)
    end

    it 'returns an array of hashes' do
      expect(repo_collaborators).to be_a_kind_of(Array)
      expect(repo_collaborators.first).to be_a_kind_of(Hash)
    end
  end

  describe Coderwall::Github::Queries::Repo::ForksFor do
    let(:github_username) { 'assemblymade' }
    let(:repo_name) { 'coderwall' }

    subject { Coderwall::Github::Queries::Repo::ForksFor.new(client, github_username, repo_name) }

    let(:repo_forks) {
      VCR.use_cassette('fetch assemblymade/coderwall repo forks') do
        subject.fetch
      end
    }

    it 'inherits from Queries::Base' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Base)
    end

    it 'inherits from Queries::Repo::Base' do
      expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Repo::Base)
    end

    it 'fetchs just3ws coderwall repo forks' do
      expect(repo_forks.first.keys.count).to eq(67)
    end

    it 'returns an array of hashes' do
      expect(repo_forks).to be_a_kind_of(Array)
      expect(repo_forks.first).to be_a_kind_of(Hash)
    end
  end
end
