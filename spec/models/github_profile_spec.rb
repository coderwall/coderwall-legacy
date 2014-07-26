require 'vcr_helper'

# TODO: Deprecate GithubOld, and related testing
RSpec.describe GithubProfile, :type => :model, skip: ENV['TRAVIS']  do
  let(:languages) {
    {
      'C' => 194738,
      'C++' => 105902,
      'Perl' => 2519686
    }
  }
  ## test we don't create a fact for an empty repo
  let(:access_token) { '9432ed76b16796ec034670524d8176b3f5fee9aa' }
  let(:client_id) { '974695942065a0e00033' }
  let(:client_secret) { '7d49c0deb57b5f6c75e6264ca12d20d6a8ffcc68' }

  it 'should have a timesamp' do
    profile = Fabricate(:github_profile)
    expect(profile.created_at).not_to be_nil
    expect(profile.updated_at).not_to be_nil
  end

  def response_body(file)
    File.read(File.join(Rails.root, "spec", 'fixtures', 'githubv3', file))
  end

  describe 'facts' do
    let (:profile) {
      VCR.use_cassette('github_profile_for_mdeiters') do
        GithubProfile.for_username('mdeiters')
      end
    }

    it 'creates facts for original repos' do
      expect(profile.facts).not_to be_empty
      fact = profile.facts.select { |fact| fact.identity =~ /mdeiters\/semr:mdeiters$/i }.first

      expect(fact.identity).to eq('https://github.com/mdeiters/semr:mdeiters')
      expect(fact.owner).to eq("github:mdeiters")
      expect(fact.name).to eq('semr')
      expect(fact.relevant_on.to_date).to eq(Date.parse('2008-05-08'))
      expect(fact.url).to eq('https://github.com/mdeiters/semr')
      expect(fact.tags).to include('repo')
      expect(fact.metadata[:languages]).to include("Ruby", "JavaScript")
    end

    it 'creates facts for when user signed up' do
      expect(profile.facts).not_to be_empty
      fact = profile.facts.last
      expect(fact.identity).to eq('github:mdeiters')
      expect(fact.owner).to eq("github:mdeiters")
      expect(fact.name).to eq('Joined GitHub')
      expect(fact.relevant_on.to_date).to eq(Date.parse('2008-04-14'))
      expect(fact.url).to eq('https://github.com/mdeiters')
      expect(fact.tags).to include('account-created')
    end
  end

  describe 'profile not on file' do
    let (:profile) {
      VCR.use_cassette('github_profile_for_mdeiters') do
        GithubProfile.for_username('mdeiters')
      end
    }

    it 'will indicate stale if older then an 24 hours', skip: 'timezone is incorrect' do
      expect(profile.updated_at).to be > 1.minute.ago
      expect(profile).not_to be_stale
      expect(profile).to receive(:updated_at).and_return(25.hours.ago)
      expect(profile).to be_stale
    end

    it 'builds a profile if there is none on file' do
      expect(profile.name).to eq('Matthew Deiters')
    end

    it 'populates followers' do
      expect(profile.followers.map { |f| f[:login] }).to include('amanelis')
    end

    it 'populates following' do
      expect(profile.following.map { |f| f[:login] }).to include('atmos')
    end

    it 'populates watched repos' do
      expect(profile.watched.map { |w| w[:name] }).to include('rails')
    end

    describe 'populates owned repos' do
      before do
        @repo = GithubRepo.find(profile.repos.first[:id])
      end

      it 'gets a list of repos' do
        expect(profile.repos.map { |r| r[:name] }).to include ('semr')
      end

      it 'adds languages' do
        expect(@repo.language).to eq('Ruby')
      end

      it 'adds watchers' do
        expect(@repo.followers.first.login).to eq('mdeiters')
      end

      it 'adds contributors', skip: 'fragile integration' do
        expect(@repo.contributors.first['login']).to eq('mdeiters')
      end

      it 'adds forks', skip: 'fragile integration' do
        expect(@repo.forks.size).to eq(1)
      end
    end
  end
end
