require 'spec_helper'

RSpec.describe Lanyrd, type: :model, functional: true do
  it 'should pull events for user' do
    lanyrd = Lanyrd.new('mdeiters')
    expect(lanyrd.facts.size).to be >= 3

    event = lanyrd.facts.first

    expect(event.identity).to eq('/2011/speakerconf-rome/:mdeiters')
    expect(event.owner).to eq('lanyrd:mdeiters')
    expect(event.name).to eq("Speaker Conf")
    expect(event.relevant_on.to_date).to eq(Date.parse('2011-09-11'))
    expect(event.url).to eq('http://lanyrd.com/2011/speakerconf-rome/')
    expect(event.tags).to include('event', 'Software', 'Technology')
  end

  skip 'should pull future events'

  it 'should return no events for a user that does not exist' do
    deck = Lanyrd.new('asfjkdsfkjldsafdskljfdsdsfdsafas')
    expect(deck.facts).to be_empty
  end

end
