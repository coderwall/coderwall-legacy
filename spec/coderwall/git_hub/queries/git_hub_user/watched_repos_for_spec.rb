require_relative '../queries_spec_helper'

describe Coderwall::GitHub::Queries::GitHubUser::WatchedReposFor do
  include_context :github_shared_context

  subject { Coderwall::GitHub::Queries::GitHubUser::WatchedReposFor.new(client, github_username) }

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
    Coderwall::GitHub::Queries::GitHubUser::WatchedReposFor.exclude_attributes do |exclude_attribute|
      expect(watched_repos.first.has_key?(exclude_attribute)).to be false
    end
  end
end
