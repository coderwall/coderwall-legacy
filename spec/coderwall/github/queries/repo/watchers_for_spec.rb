require_relative '../queries_spec_helper'

describe Coderwall::Github::Queries::Repo::WatchersFor do
  include_context :github_shared_context

  let(:github_username) { 'assemblymade' }

  let(:repo_name) { 'coderwall' }

  subject { Coderwall::Github::Queries::Repo::WatchersFor.new(client, github_username, repo_name) }

  let(:repo_watchers) {
    VCR.use_cassette('fetch assemblymade/coderwall repo watchers') do
      subject.fetch
    end
  }

  it 'inherits from Coderwall::Github::Queries::Base' do
    expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Base)
  end

  it 'inherits from Coderwall::Github::Queries::Repo::Base' do
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
