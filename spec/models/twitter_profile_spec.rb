require 'spec_helper'

describe TwitterProfile, pending: 'Twitter REST API v1 is obsolete' do

  let(:response) { File.read(File.join(Rails.root, 'spec', 'fixtures', 'twitter', 'user_timeline.js')) }

  it 'should be able to retrieve profile by username' do
    twitter = TwitterProfile.create!(username: 'mdeiters')
    TwitterProfile.for_username('mdeiters').should == twitter
  end

  it 'should build profile if it doesnt exsist' do
    stub_request(:get, 'https://api.twitter.com/1/statuses/user_timeline.json?count=200&screen_name=mdeiters&trim_user=true').to_return(body: response)
    profile = TwitterProfile.for_username('mdeiters')
    profile.should_not be_nil
  end

  it 'should get most recent tweet' do
    stub_request(:get, 'https://api.twitter.com/1/statuses/user_timeline.json?count=200&screen_name=mdeiters&trim_user=true').to_return(body: response)
    profile = TwitterProfile.for_username('mdeiters')
    profile.refresh_timeline!
    profile.most_recent_tweet.tweet_id.should == 99240505124200448
  end

  it 'refreshes should retrieve latest tweets' do
    stub_request(:get, 'https://api.twitter.com/1/statuses/user_timeline.json?count=200&screen_name=mdeiters&trim_user=true').to_return(body: response)
    profile = TwitterProfile.for_username('mdeiters')
    profile.refresh_timeline!
    since_last_tweet_response = File.read(File.join(Rails.root, 'spec', 'fixtures', 'twitter', 'user_timeline2.js'))
    FakeWeb.register_uri(:get, 'http://api.twitter.com/1/statuses/user_timeline.json?count=200&screen_name=mdeiters&trim_user=true&since_id=99240505124200448', body: since_last_tweet_response.strip)
    profile.refresh_timeline!
    profile.most_recent_tweet.tweet_id.should == 98482564595073024
  end

  it 'should create links for the user with their achievement count as a score' do
    stub_request(:get, 'https://api.twitter.com/1/statuses/user_timeline.json?count=200&screen_name=mdeiters&trim_user=true').to_return(body: response)
    Timecop.travel("08/10/2011") do
      profile = TwitterProfile.for_username('mdeiters')
      profile.refresh_timeline!
      profile.recent_links.should include("http://hi.com")
    end
  end

end
