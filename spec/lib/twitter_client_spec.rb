describe TwitterClient, pending: 'Twitter REST API v1 is no longer active' do
  it 'should get feed for a user', functional: true do
    timeline = VCR.use_cassette('twitter_timeline_for_coderwall') do
      TwitterClient.timeline_for('coderwall')
    end
    timeline.should_not be_empty
  end

  it 'should get feed for a user since a previous feed', functional: true do
    timeline = VCR.use_cassette('twitter_timeline_for_coderwall') do
      TwitterClient.timeline_for('coderwall')
    end
    TwitterClient.timeline_for('coderwall', timeline[0]['id_str']).should be_empty
    TwitterClient.timeline_for('coderwall', timeline[1]['id_str']).count.should == 1
  end
end
