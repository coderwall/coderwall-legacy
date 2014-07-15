RSpec.describe Bitbucket, type: :model do
  describe 'facts' do
    before(:all) do
      stub_request(:get, 'https://api.bitbucket.org/1.0/users/jespern').to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'bitbucketv1', 'repositories.js')))
      stub_request(:get, 'https://api.bitbucket.org/1.0/users/jespern/followers').to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'bitbucketv1', 'user_followers.js')))
      stub_request(:get, 'https://bitbucket.org/jespern').to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'bitbucketv1', 'user_profile.js')))

      [{ repo: 'django-piston', commits: 297 },
       { repo: 'par2-drobofs', commits: 0 },
       { repo: 'heechee-fixes', commits: 18 }].each do |info|
         stub_request(:get, "https://api.bitbucket.org/1.0/repositories/jespern/#{info[:repo]}").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'bitbucketv1', 'repositories', "#{info[:repo]}.js")))
         stub_request(:get, "https://api.bitbucket.org/1.0/repositories/jespern/#{info[:repo]}/followers").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'bitbucketv1', 'repositories', "#{info[:repo]}_followers.js")))
         stub_request(:get, "https://api.bitbucket.org/1.0/repositories/jespern/#{info[:repo]}/src/tip/README.rst").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'bitbucketv1', 'repositories', "#{info[:repo]}_followers.js")))
         stub_request(:get, "https://bitbucket.org/jespern/#{info[:repo]}/descendants").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'bitbucketv1', 'repositories', "#{info[:repo]}_forks.js")))

         0.step(info[:commits], 50) do |start|
           stub_request(:get, "https://api.bitbucket.org/1.0/repositories/jespern/#{info[:repo]}/events?type=commit&limit=50&start=#{start}").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'bitbucketv1', 'repositories', "#{info[:repo]}_commits.js")))
         end
       end

      @bitbucket = Bitbucket::V1.new('jespern')
      @bitbucket.update_facts!
    end

    it 'creates facts for original repos' do
      expect(@bitbucket.facts).not_to be_empty
      fact = @bitbucket.facts.first
      expect(fact.identity).to eq('https://bitbucket.org/jespern/django-piston/overview:jespern')
      expect(fact.owner).to eq('bitbucket:jespern')
      expect(fact.name).to eq('django-piston')
      expect(fact.relevant_on.to_date).to eq(Date.parse('2009-04-19'))
      expect(fact.url).to eq('https://bitbucket.org/jespern/django-piston/overview')
      expect(fact.tags).to include('repo', 'bitbucket', 'personal', 'original', 'Python', 'Django')
      expect(fact.metadata[:languages]).to include('Python')
      expect(fact.metadata[:original]).to be_truthy
      expect(fact.metadata[:times_forked]).to eq(243)
      expect(fact.metadata[:watchers].first).to be_a_kind_of String
      expect(fact.metadata[:watchers].count).to eq(983)
      expect(fact.metadata[:website]).to eq('http://bitbucket.org/jespern/')
    end

    it 'creates facts for small repos' do
      expect(@bitbucket.facts.count).to eq(3)
      expect(@bitbucket.repos.map(&:name)).not_to include('par2-drobofs')
    end

    it 'creates facts for forked repos' do
      expect(@bitbucket.facts).not_to be_empty
      fact = @bitbucket.facts.second
      expect(fact.identity).to eq('https://bitbucket.org/jespern/heechee-fixes/overview:jespern')
      expect(fact.owner).to eq('bitbucket:jespern')
      expect(fact.name).to eq('heechee-fixes')
      expect(fact.relevant_on.to_date).to eq(Date.parse('2010-04-14'))
      expect(fact.url).to eq('https://bitbucket.org/jespern/heechee-fixes/overview')
      expect(fact.tags).to include('repo', 'bitbucket', 'personal', 'fork')
      expect(fact.metadata[:languages]).to be_empty
      expect(fact.metadata[:original]).to be_falsey
      expect(fact.metadata[:times_forked]).to eq(0)
      expect(fact.metadata[:watchers].count).to eq(2)
      expect(fact.metadata[:website]).to be_nil
    end

    it 'creates facts for when user signed up' do
      expect(@bitbucket.facts).not_to be_empty
      fact = @bitbucket.facts.last
      expect(fact.identity).to eq('bitbucket:jespern')
      expect(fact.owner).to eq('bitbucket:jespern')
      expect(fact.name).to eq('Joined Bitbucket')
      expect(fact.relevant_on.to_date).to eq(Date.parse('2008-06-13'))
      expect(fact.url).to eq('https://bitbucket.org/jespern')
      expect(fact.tags).to include('bitbucket', 'account-created')
      expect(fact.tags).to include('account-created')
      expect(fact.metadata[:avatar_url]).to eq('https://secure.gravatar.com/avatar/b658715b9635ef057daf2a22d4a8f36e?d=identicon&s=32')
      expect(fact.metadata[:followers].count).to eq(218)
    end

    it 'should fail gracefully if bitbucket user does not exist', functional: true do
      @bitbucket = Bitbucket::V1.new(bad_username_used_in_prod = 'someone@example.com')
      @bitbucket.update_facts!
    end

    it 'able to get join date', functional: true do
      @bitbucket = Bitbucket::V1.new(bad_username_used_in_prod = 'm')
      @bitbucket.update_facts!
    end
  end
end
