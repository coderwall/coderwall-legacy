require 'spec_helper'

describe Github, functional: true do
  let(:github) { Github.new }

  it 'can get profile' do
    github.profile('mdeiters')[:name].should == 'Matthew Deiters'
  end

  it 'can get orgs' do
    github.orgs_for('defunkt', 2.years.ago).first['login'].should == 'github'
  end

  it 'can get followers' do
    github.followers_for('mdeiters').map { |follower| follower['login'] }.should include('alexrothenberg')
  end

  it 'gets all followers if multiple pages' do
    total_followers = github.followers_for('obie').size
    total_followers.should > 200
  end

  it 'gets all repos for user' do
    github.repos_for('mdeiters').map { |follower| follower['name'] }.should include('travis-ci')
  end

  it 'gets all watched repos for user' do
    github.watched_repos_for('mdeiters').map { |repo| repo[:name] }.should include('readraptor')
  end

  it 'gets watchers of a repo' do
    github.repo_watchers('mdeiters', 'semr', 10.years.ago).first[:login].should == 'pius'
  end

  it 'gets languages of a repo' do
    github.repo_languages('mdeiters', 'semr', 2.years.ago).should include("Ruby", "JavaScript")
  end

  it 'gets contributors of a repo' do
    github.repo_contributors('mdeiters', 'healthy', 2.years.ago).collect { |r| r[:login] }.should include("flyingmachine")
  end

  it 'recovers if getting contributors errors out' do
    lambda { github.repo_contributors('dmtrs', 'EJNestedTreeActions', 2.years.ago) }.should_not raise_error
  end

  it 'gets all forks of a repo' do
    github.repo_forks('mdeiters', 'semr', 2.years.ago).collect { |r| r[:owner][:login] }.should include('derfred')
  end

  it 'should scope requests by user' do
    daniel = Github.new(daniel_h = '697b68755f419b475299873164e3c60fca21ae58')
    daniel.profile['login'].should == 'flyingmachine'
  end

  it 'should scope requests by user but allow override' do
    daniel = Github.new(daniel_h = '697b68755f419b475299873164e3c60fca21ae58')
    daniel.profile['login'].should_not == daniel.profile('bguthrie')['login']
  end
end
