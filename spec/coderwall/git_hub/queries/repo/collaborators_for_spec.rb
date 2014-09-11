require_relative '../queries_spec_helper'

describe Coderwall::GitHub::Queries::Repo::CollaboratorsFor do
  include_context :github_shared_context

  let(:github_username) { 'assemblymade' }

  let(:repo_name) { 'coderwall' }

  subject { Coderwall::GitHub::Queries::Repo::CollaboratorsFor.new(client, github_username, repo_name) }

  let(:repo_collaborators) {
    VCR.use_cassette('fetch assemblymade/coderwall repo collaborators') do
      subject.fetch
    end
  }

  it 'inherits from Coderwall::GitHub::Queries::Base' do
    expect(subject).to be_a_kind_of(Coderwall::GitHub::Queries::Base)
  end

  it 'inherits from Coderwall::GitHub::Queries::Repo::Base' do
    expect(subject).to be_a_kind_of(Coderwall::GitHub::Queries::Repo::Base)
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
