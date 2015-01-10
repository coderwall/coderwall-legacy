require 'spec_helper'

RSpec.describe Changelogd, type: :model, skip: true do
  it 'should award a user if there is a tag' do
    stub_request(:get, Changelogd::API_URI).to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'changelogd_feed.xml')))
    Changelogd.quick_refresh

    user = Fabricate(:user, github: 'CloudMade')

    changelogd = Changelogd.new(user)
    expect(changelogd.award?).to eq(true)
    expect(changelogd.reasons[:links].first['Leaflet']).to eq('http://github.com/CloudMade/Leaflet')
  end

  it 'should have a name and description' do
    expect(Changelogd.name).not_to be_blank
    expect(Changelogd.description).not_to be_blank
  end

  it 'should should find github projects' do
    stub_request(:get, Changelogd::API_URI).to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'changelogd_feed.xml')))
    expect(Changelogd.latest_repos.first).to eq('http://github.com/CloudMade/Leaflet')
  end

  it 'should create a fact' do
    stub_request(:get, Changelogd::API_URI).to_return(body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'changelogd_feed.xml')))
    Changelogd.quick_refresh
    fact = Fact.where(identity: 'http://github.com/CloudMade/Leaflet:changedlogd').first
    expect(fact).not_to be_nil
  end

  it 'should find the first and last project', functional: true, slow: true, skip: 'resource not found' do
    expect(Changelogd.all_repos).to include('http://github.com/kennethreitz/tablib')
    expect(Changelogd.all_repos).to include('http://github.com/johnsheehan/RestSharp')
  end

  it 'should find repos in episodes too', functional: true, skip: 'resource not found' do
    expect(Changelogd.all_repos).to include('https://github.com/geemus/excon')
  end
end
