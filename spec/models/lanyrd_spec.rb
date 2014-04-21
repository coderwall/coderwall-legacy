require 'spec_helper'

describe Lanyrd, functional: true, pending: 'expected data has changed' do
  it 'should pull events for user' do
    lanyrd = Lanyrd.new('mdeiters')
    lanyrd.facts.size.should >= 3

    event = lanyrd.facts.first

    event.identity.should == '/2011/speakerconf-rome/:mdeiters'
    event.owner.should == 'lanyrd:mdeiters'
    event.name.should == "Speaker Conf"
    event.relevant_on.to_date.should == Date.parse('2011-09-11')
    event.url.should == 'http://lanyrd.com/2011/speakerconf-rome/'
    event.tags.should include('event', 'Software', 'Technology')
  end

  pending 'should pull future events'

  it 'should return no events for a user that does not exist' do
    deck = Lanyrd.new('asfjkdsfkjldsafdskljfdsdsfdsafas')
    deck.facts.should be_empty
  end

end
