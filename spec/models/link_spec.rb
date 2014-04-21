require 'spec_helper'

describe Link do
  let(:url) { "http://test.google.com" }
  before :each do
    #FakeWeb.register_uri(:get, 'http://test.google.com/', body: 'OK')
  end

  it 'retrieves popular links with score higher then 2 and has at least 2 or mor users' do
    enough_users = Link.create!(score: 8, user_ids: [1, 2])
    not_enought_user = Link.create!(score: 3, user_ids: [1])
    Link.popular.all.collect.should include(enough_users)
    Link.popular.all.collect.should_not include(not_enought_user)
  end

  describe 'featuring' do
    before :each do
      @earliest = Link.create!(featured_on: 1.day.ago)
      @latest = Link.create!(featured_on: 1.hour.ago)
      @not_featured = Link.create!()
    end

    it 'finds items featured by featured date' do
      Link.featured.first.should == @latest
      Link.featured.last.should == @earliest
      Link.featured.should_not include(@not_featured)
    end

    it 'finds items not featured' do
      Link.not_featured.should_not include(@latest)
      Link.not_featured.should_not include(@earliest)
      Link.not_featured.should include(@not_featured)
    end
  end

  it 'expands twitter urls', functional: true do
    Link.expand_url('http://t.co/eWplTxA').should == 'https://github.com/RailsApps/rails3-application-templates'
  end

  it 'expands bitly urls', functional: true do
    Link.expand_url('http://bit.ly/pPzKX5').should == 'http://lokka.org/if-you-forget-a-password'
  end

  it 'should find links for a user' do
    the_link = Link.create!(url: url, user_ids: [123])
    Link.for_user(123).should include(the_link)
    Link.for_user(444).should_not include(the_link)
  end
end
