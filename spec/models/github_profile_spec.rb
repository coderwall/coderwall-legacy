describe GithubProfile, :pending do
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
    profile.created_at.should_not be_nil
    profile.updated_at.should_not be_nil
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
      profile.facts.should_not be_empty
      fact = profile.facts.select { |fact| fact.identity =~ /mdeiters\/semr:mdeiters$/i }.first

      fact.identity.should == 'https://github.com/mdeiters/semr:mdeiters'
      fact.owner.should == "github:mdeiters"
      fact.name.should == 'semr'
      fact.relevant_on.to_date.should == Date.parse('2008-05-08')
      fact.url.should == 'https://github.com/mdeiters/semr'
      fact.tags.should include('repo')
      fact.metadata[:languages].should include("Ruby", "JavaScript")
    end

    it 'creates facts for when user signed up' do
      profile.facts.should_not be_empty
      fact = profile.facts.last
      fact.identity.should == 'github:mdeiters'
      fact.owner.should == "github:mdeiters"
      fact.name.should == 'Joined GitHub'
      fact.relevant_on.to_date.should == Date.parse('2008-04-14')
      fact.url.should == 'https://github.com/mdeiters'
      fact.tags.should include('account-created')
    end
  end

  describe 'profile not on file' do
    let (:profile) {
      VCR.use_cassette('github_profile_for_mdeiters') do
        GithubProfile.for_username('mdeiters')
      end
    }

    it 'will indicate stale if older then an 24 hours', pending: 'timezone is incorrect' do
      profile.updated_at.should > 1.minute.ago
      profile.should_not be_stale
      profile.should_receive(:updated_at).and_return(25.hours.ago)
      profile.should be_stale
    end

    it 'builds a profile if there is none on file' do
      profile.name.should == 'Matthew Deiters'
    end

    it 'populates followers' do
      profile.followers.map { |f| f[:login] }.should include('amanelis')
    end

    it 'populates following' do
      profile.following.map { |f| f[:login] }.should include('atmos')
    end

    it 'populates watched repos' do
      profile.watched.map { |w| w[:name] }.should include('rails')
    end

    describe 'populates owned repos' do
      before do
        @repo = GithubRepo.find(profile.repos.first[:id])
      end

      it 'gets a list of repos' do
        profile.repos.map { |r| r[:name] }.should include ('semr')
      end

      it 'adds languages' do
        @repo.language.should == 'Ruby'
      end

      it 'adds watchers' do
        @repo.followers.first.login.should == 'mdeiters'
      end

      it 'adds contributors', pending: 'fragile integration' do
        @repo.contributors.first['login'].should == 'mdeiters'
      end

      it 'adds forks', pending: 'fragile integration' do
        @repo.forks.size.should == 1
      end
    end
  end
end
