require_relative '../queries_spec_helper'

describe Coderwall::Github::Queries::GithubUser::ReposFor do
  include_context :github_shared_context

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
