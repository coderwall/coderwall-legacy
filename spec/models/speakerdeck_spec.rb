require 'spec_helper'

describe 'speakerdeck', functional: true do

  it 'should pull events for user' do
    deck = Speakerdeck.new('jnunemaker')
    deck.facts.size.should > 5

    event = deck.facts.last
    event.identity.should == '4cbf544157530814c0000006'
    event.owner.should == 'speakerdeck:jnunemaker'
    event.name.should == 'MongoMapper - Mapping Ruby To and From Mongo'
    event.relevant_on.to_date.should == Date.parse('2010-10-20')
    event.url.should == 'https://speakerdeck.com/jnunemaker/mongomapper-mapping-ruby-to-and-from-mongo'
    event.tags.should include('speakerdeck', 'presentation')
  end

  it 'should return no events for a user that does not exist' do
    deck = Speakerdeck.new('asfjkdsfkjldsafdskljfdsdsfdsafas')
    deck.facts.should be_empty
  end

end