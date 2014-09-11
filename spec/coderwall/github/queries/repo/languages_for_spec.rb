require_relative '../queries_spec_helper'

describe Coderwall::Github::Queries::Repo::LanguagesFor do
  include_context :github_shared_context

  let(:repo_name) { 'coderwall' }

  subject { Coderwall::Github::Queries::Repo::LanguagesFor.new(client, github_username, repo_name) }

  let(:repo_languages) {
    VCR.use_cassette('fetch just3ws/coderwall repo languages') do
      subject.fetch
    end
  }

  it 'inherits from Coderwall::Github::Queries::Base' do
    expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Base)
  end

  it 'inherits from Coderwall::Github::Queries::Repo::Base' do
    expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Repo::Base)
  end

  it 'fetchs just3ws coderwall repo languages' do
    expect(repo_languages).to have_key(:Ruby)
  end

  it 'returns a hash' do
    expect(repo_languages).to be_a_kind_of(Hash)
  end
end

