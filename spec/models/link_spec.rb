require 'spec_helper'

RSpec.describe Link, :type => :model do
  let(:url) { "http://test.google.com" }
  before :each do
    #FakeWeb.register_uri(:get, 'http://test.google.com/', body: 'OK')
  end

  it 'retrieves popular links with score higher then 2 and has at least 2 or mor users' do
    enough_users = Link.create!(score: 8, user_ids: [1, 2])
    not_enought_user = Link.create!(score: 3, user_ids: [1])
    expect(Link.popular.all.collect).to include(enough_users)
    expect(Link.popular.all.collect).not_to include(not_enought_user)
  end

  describe 'featuring' do
    before :each do
      @earliest = Link.create!(featured_on: 1.day.ago)
      @latest = Link.create!(featured_on: 1.hour.ago)
      @not_featured = Link.create!()
    end

    it 'finds items featured by featured date' do
      expect(Link.featured.first).to eq(@latest)
      expect(Link.featured.last).to eq(@earliest)
      expect(Link.featured).not_to include(@not_featured)
    end

    it 'finds items not featured' do
      expect(Link.not_featured).not_to include(@latest)
      expect(Link.not_featured).not_to include(@earliest)
      expect(Link.not_featured).to include(@not_featured)
    end
  end

  it 'expands twitter urls', functional: true do
    expect(Link.expand_url('http://t.co/eWplTxA')).to eq('https://github.com/RailsApps/rails3-application-templates')
  end

  it 'expands bitly urls', functional: true do
    expect(Link.expand_url('http://bit.ly/pPzKX5')).to eq('http://lokka.org/if-you-forget-a-password')
  end

  it 'should find links for a user' do
    the_link = Link.create!(url: url, user_ids: [123])
    expect(Link.for_user(123)).to include(the_link)
    expect(Link.for_user(444)).not_to include(the_link)
  end
end
