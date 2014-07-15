require 'spec_helper'

RSpec.describe ServiceResponse do
  let(:response) { ServiceResponse.new(body = '', headers) }
  let(:headers) do {
    status: '200 OK', date: 'Fri, 24 Jun 2011 19:53:08 GMT',
    x_ratelimit_limit: '5000',
    transfer_encoding: 'chunked',
    x_ratelimit_remaining: '4968',
    content_encoding: 'gzip',
    link: "<https://api.github.com/users/defunkt/followers?page=2&per_page=>100>; rel=\"next\", <https://api.github.com/users/defunkt/followers?page=97&per_page=>100>; rel=\"last\"",
    content_type: 'application/json',
    server: 'nginx/0.7.67', connection: 'keep-alive' }
  end

  it 'indicates more results if it has next link header' do
    expect(response.more?).to eq(true)
  end

  it 'indicates next result' do
    expect(response.next_page).to eq('https://api.github.com/users/defunkt/followers?page=2&per_page=>100')
  end
end
