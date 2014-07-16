RSpec.describe Github, type: :model, functional: true, skip: ENV['TRAVIS']  do
  let(:github) { Github.new }

  it 'can get profile' do
    expect(github.profile('mdeiters')[:name]).to eq('Matthew Deiters')
  end

  it 'can get orgs' do
    expect(github.orgs_for('defunkt', 2.years.ago).first['login']).to eq('github')
  end

  it 'can get followers' do
    expect(github.followers_for('mdeiters').map { |follower| follower['login'] }).to include('alexrothenberg')
  end

  it 'gets all followers if multiple pages' do
    total_followers = github.followers_for('obie').size
    expect(total_followers).to be > 200
  end

  it 'gets all repos for user' do
    expect(github.repos_for('mdeiters').map { |follower| follower['name'] }).to include('travis-ci')
  end

  it 'gets all watched repos for user' do
    expect(github.watched_repos_for('mdeiters').map { |repo| repo[:name] }).to include('readraptor')
  end

  it 'gets watchers of a repo' do
    expect(github.repo_watchers('mdeiters', 'semr', 10.years.ago).first[:login]).to eq('pius')
  end

  it 'gets languages of a repo' do
    expect(github.repo_languages('mdeiters', 'semr', 2.years.ago)).to include("Ruby", "JavaScript")
  end

  it 'gets contributors of a repo' do
    expect(github.repo_contributors('mdeiters', 'healthy', 2.years.ago).collect { |r| r[:login] }).to include("flyingmachine")
  end

  it 'recovers if getting contributors errors out' do
    expect { github.repo_contributors('dmtrs', 'EJNestedTreeActions', 2.years.ago) }.not_to raise_error
  end

  it 'gets all forks of a repo' do
    expect(github.repo_forks('mdeiters', 'semr', 2.years.ago).collect { |r| r[:owner][:login] }).to include('derfred')
  end

  it 'should scope requests by user' do
    daniel = Github.new(daniel_h = '697b68755f419b475299873164e3c60fca21ae58')
    expect(daniel.profile['login']).to eq('flyingmachine')
  end

  it 'should scope requests by user but allow override' do
    daniel = Github.new(daniel_h = '697b68755f419b475299873164e3c60fca21ae58')
    expect(daniel.profile['login']).not_to eq(daniel.profile('bguthrie')['login'])
  end
end
