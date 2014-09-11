require_relative '../queries_spec_helper'

describe Coderwall::Github::Queries::GithubUser::ProfileFor do
  include_context :github_shared_context

  subject { Coderwall::Github::Queries::GithubUser::ProfileFor.new(client, github_username) }

  let(:user) {
    VCR.use_cassette('fetch github user for just3ws') do
      subject.fetch
    end
  }

  it 'sets the client reader' do
    expect(subject.client).to_not be_nil
  end

  it 'inherits from Coderwall::Github::Queries::Base' do
    expect(subject).to be_a_kind_of(Coderwall::Github::Queries::Base)
  end

  it 'inherits from Coderwall::Github::Queries::GithubUser::Base' do
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
