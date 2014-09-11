require_relative '../queries_spec_helper'

describe Coderwall::GitHub::Queries::GitHubUser::ProfileFor do
  include_context :github_shared_context

  subject { Coderwall::GitHub::Queries::GitHubUser::ProfileFor.new(client, github_username) }

  let(:user) {
    VCR.use_cassette('fetch github user for just3ws') do
      subject.fetch
    end
  }

  it 'sets the client reader' do
    expect(subject.client).to_not be_nil
  end

  it 'inherits from Coderwall::GitHub::Queries::Base' do
    expect(subject).to be_a_kind_of(Coderwall::GitHub::Queries::Base)
  end

  it 'inherits from Coderwall::GitHub::Queries::GitHubUser::Base' do
    expect(subject).to be_a_kind_of(Coderwall::GitHub::Queries::GitHubUser::Base)
  end

  it 'returns a hash' do
    expect(user).to be_a_kind_of(Hash)
  end

  it 'filters the user attribute' do
    Coderwall::GitHub::Queries::GitHubUser::ProfileFor.exclude_attributes do |exclude_attribute|
      expect(user.has_key?(exclude_attribute)).to be false
    end
  end
end
