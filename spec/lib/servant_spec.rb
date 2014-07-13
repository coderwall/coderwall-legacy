RSpec.describe Servant do
  let(:url) { 'http://www.google.com' }

  it 'captures calls to api' do
    stub_request(:get, url).to_return(body: 'TESTING')

    expect(Servant.capture_api_calls do
      Servant.get(url)
      Servant.get(url)
    end).to eq(2)

    expect(Servant.capture_api_calls do
      Servant.get(url)
      Servant.get(url)
      Servant.get(url)
      Servant.get(url)
    end).to eq(4)
  end
end
