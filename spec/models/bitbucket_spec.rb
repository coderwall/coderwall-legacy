describe Bitbucket do
  describe 'facts' do
    before(:all) do
      stub_request(:get, 'https://api.bitbucket.org/1.0/users/jespern').to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'bitbucketv1', 'repositories.js')))
      stub_request(:get, 'https://api.bitbucket.org/1.0/users/jespern/followers').to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'bitbucketv1', 'user_followers.js')))
      stub_request(:get, "https://bitbucket.org/jespern").to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'bitbucketv1', "user_profile.js")))

      [{repo: 'django-piston', commits: 297},
       {repo: 'par2-drobofs', commits: 0},
       {repo: 'heechee-fixes', commits: 18}].each do |info|
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
      @bitbucket.facts.should_not be_empty
      fact = @bitbucket.facts.first
      fact.identity.should == 'https://bitbucket.org/jespern/django-piston/overview:jespern'
      fact.owner.should == "bitbucket:jespern"
      fact.name.should == 'django-piston'
      fact.relevant_on.to_date.should == Date.parse('2009-04-19')
      fact.url.should == 'https://bitbucket.org/jespern/django-piston/overview'
      fact.tags.should include('repo', 'bitbucket', 'personal', 'original', 'Python', 'Django')
      fact.metadata[:languages].should include("Python")
      fact.metadata[:original].should be_true
      fact.metadata[:times_forked].should == 243
      fact.metadata[:watchers].first.should be_a_kind_of String
      fact.metadata[:watchers].count.should == 983
      fact.metadata[:website].should == "http://bitbucket.org/jespern/"
    end

    it 'creates facts for small repos' do
      @bitbucket.facts.count.should == 3
      @bitbucket.repos.collect(&:name).should_not include('par2-drobofs')
    end

    it 'creates facts for forked repos' do
      @bitbucket.facts.should_not be_empty
      fact = @bitbucket.facts.second
      fact.identity.should == 'https://bitbucket.org/jespern/heechee-fixes/overview:jespern'
      fact.owner.should == 'bitbucket:jespern'
      fact.name.should == 'heechee-fixes'
      fact.relevant_on.to_date.should == Date.parse('2010-04-14')
      fact.url.should == 'https://bitbucket.org/jespern/heechee-fixes/overview'
      fact.tags.should include('repo', 'bitbucket', 'personal', 'fork')
      fact.metadata[:languages].should be_empty
      fact.metadata[:original].should be_false
      fact.metadata[:times_forked].should == 0
      fact.metadata[:watchers].count.should == 2
      fact.metadata[:website].should be_nil
    end

    it 'creates facts for when user signed up' do
      @bitbucket.facts.should_not be_empty
      fact = @bitbucket.facts.last
      fact.identity.should == 'bitbucket:jespern'
      fact.owner.should == "bitbucket:jespern"
      fact.name.should == 'Joined Bitbucket'
      fact.relevant_on.to_date.should == Date.parse('2008-06-13')
      fact.url.should == 'https://bitbucket.org/jespern'
      fact.tags.should include('bitbucket', 'account-created')
      fact.tags.should include('account-created')
      fact.metadata[:avatar_url].should == "https://secure.gravatar.com/avatar/b658715b9635ef057daf2a22d4a8f36e?d=identicon&s=32"
      fact.metadata[:followers].count.should == 218
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
