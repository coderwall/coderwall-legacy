require_relative '../queries_spec_helper'

describe Coderwall::Github::Queries::GithubUser::FollowersFor do
  include_context :github_shared_context

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
