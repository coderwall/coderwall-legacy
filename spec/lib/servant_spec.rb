describe Servant do
  let(:url) { 'http://www.google.com' }

  it 'captures calls to api' do
    stub_request(:get, url).to_return(body: 'TESTING')

    Servant.capture_api_calls do
      Servant.get(url)
      Servant.get(url)
    end.should == 2

    Servant.capture_api_calls do
      Servant.get(url)
      Servant.get(url)
      Servant.get(url)
      Servant.get(url)
    end.should == 4
  end
end
