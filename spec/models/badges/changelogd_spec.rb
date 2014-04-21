require 'spec_helper'

describe Changelogd do
  it 'should award a user if there is a tag' do
    stub_request(:get, Changelogd::API_URI).to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'changelogd_feed.xml')))
    Changelogd.quick_refresh

    user = Fabricate(:user, github: 'CloudMade')

    changelogd = Changelogd.new(user)
    changelogd.award?.should == true
    changelogd.reasons[:links].first['Leaflet'].should == 'http://github.com/CloudMade/Leaflet'
  end

  it 'should have a name and description' do
    Changelogd.name.should_not be_blank
    Changelogd.description.should_not be_blank
  end

  it 'should should find github projects' do
    stub_request(:get, Changelogd::API_URI).to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'changelogd_feed.xml')))
    Changelogd.latest_repos.first.should == 'http://github.com/CloudMade/Leaflet'
  end

  it 'should create a fact' do
    stub_request(:get, Changelogd::API_URI).to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'changelogd_feed.xml')))
    Changelogd.quick_refresh
    fact = Fact.where(identity: 'http://github.com/CloudMade/Leaflet:changedlogd').first
    fact.should_not be_nil
  end

  it 'should find the first and last project', functional: true, slow: true, pending: 'resource not found' do
    Changelogd.all_repos.should include('http://github.com/kennethreitz/tablib')
    Changelogd.all_repos.should include('http://github.com/johnsheehan/RestSharp')
  end

  it 'should find repos in episodes too', functional: true, pending: 'resource not found' do
    Changelogd.all_repos.should include('https://github.com/geemus/excon')
  end
end
