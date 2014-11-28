require 'rails_helper'

RSpec.describe Users::Github::Repository, type: :model do
  it { is_expected.to have_many :followers }
  it { is_expected.to have_many :contributors }
  it { is_expected.to belong_to :organization }
  it { is_expected.to belong_to :owner }

  let(:data) { JSON.parse(File.read(File.join(Rails.root, 'spec', 'fixtures', 'githubv3', 'user_repo.js'))).with_indifferent_access }
  let(:repo) do
    GithubRepo.for_owner_and_name('mdeiters', 'semr', nil, data)
  end
  let(:access_token) { '9432ed76b16796ec034670524d8176b3f5fee9aa' }
  let(:client_id) { '974695942065a0e00033' }
  let(:client_secret) { '7d49c0deb57b5f6c75e6264ca12d20d6a8ffcc68' }

end
