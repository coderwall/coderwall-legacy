require_relative '../queries_spec_helper'

describe Coderwall::Github::Queries::GithubUser::FollowingFor do
  include_context :github_shared_context

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
