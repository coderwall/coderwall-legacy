require 'spec_helper'

RSpec.describe 'slideshare', type: :model, functional: true do

  it 'should pull events for user and create protips' do
    deck = Slideshare.new('ndecrock')
    author = Fabricate(:user, slideshare: 'ndecrock')
    author.save!
    facts = deck.facts
    expect(facts.size).to be > 2

    event = facts.select { |f| f.identity == '16469108' }.first

    expect(event.identity).to eq('16469108')
    expect(event.owner).to eq('slideshare:ndecrock')
    expect(event.name).to eq("The Comeback of the Watch")
    expect(event.relevant_on.to_date.year).to eq(2013)
    expect(event.url).to eq('http://www.slideshare.net/ndecrock/the-comeback-of-the-watch')
    expect(event.tags).to include('slideshare', 'presentation')
  end

  it 'should return no events for a user that does not exist' do
    deck = Slideshare.new('asfjkdsfkjldsafdskljfdsdsfdsafas')
    expect(deck.facts).to be_empty
  end

end
