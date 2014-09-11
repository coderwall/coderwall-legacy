require_relative '../queries_spec_helper'

describe Coderwall::Github::Queries::Repo::RepoFor do
  include_context :github_shared_context

  let(:repo_name) { 'coderwall' }

  subject { Coderwall::Github::Queries::Repo::RepoFor.new(client, github_username, repo_name) }

  let(:repo) {
    VCR.use_cassette('fetch just3ws/coderwall repos') do
      subject.fetch
    end
  }

  it 'inherits from Coderwall::Github::Queries::Base' do
    expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Base)
  end

  it 'inherits from Coderwall::Github::Queries::Repo::Base' do
    expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Repo::Base)
  end

  it 'fetchs just3ws coderwall repo' do
    expect(repo[:full_name]).to be == 'just3ws/coderwall'
  end

  it 'returns a hash' do
    expect(repo).to be_a_kind_of(Hash)
  end
end
