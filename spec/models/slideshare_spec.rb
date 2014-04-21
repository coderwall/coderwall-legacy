require 'spec_helper'

describe 'slideshare', functional: true do

  it 'should pull events for user and create protips' do
    deck = Slideshare.new('ndecrock')
    author = Fabricate(:user, slideshare: 'ndecrock')
    author.save!
    facts = deck.facts
    facts.size.should > 2

    event = facts.select { |f| f.identity == '16469108' }.first

    event.identity.should == '16469108'
    event.owner.should == 'slideshare:ndecrock'
    event.name.should == "The Comeback of the Watch"
    event.relevant_on.to_date.year.should == 2013
    event.url.should == 'http://www.slideshare.net/ndecrock/the-comeback-of-the-watch'
    event.tags.should include('slideshare', 'presentation')
  end

  it 'should return no events for a user that does not exist' do
    deck = Slideshare.new('asfjkdsfkjldsafdskljfdsdsfdsafas')
    deck.facts.should be_empty
  end

end
