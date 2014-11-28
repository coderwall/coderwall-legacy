require 'vcr_helper'

RSpec.describe 'speakerdeck', type: :model, functional: true do
  it 'should pull events for user' do
    # TODO: Refactor api calls to Sidekiq job
    VCR.use_cassette('Speakerdeck') do
        deck = Speakerdeck.new('jnunemaker')
        expect(deck.facts.size).to be > 5

        event = deck.facts.last
        expect(event.identity).to eq('4cbf544157530814c0000006')
        expect(event.owner).to eq('speakerdeck:jnunemaker')
        expect(event.name).to eq('MongoMapper - Mapping Ruby To and From Mongo')
        expect(event.relevant_on.to_date).to eq(Date.parse('2010-10-20'))
        expect(event.url).to eq('https://speakerdeck.com/jnunemaker/mongomapper-mapping-ruby-to-and-from-mongo')
        expect(event.tags).to include('speakerdeck', 'presentation')
      end
  end

  it 'should return no events for a user that does not exist' do
    # TODO: Refactor api calls to Sidekiq job
    VCR.use_cassette('Speakerdeck') do
      deck = Speakerdeck.new('asfjkdsfkjldsafdskljfdsdsfdsafas')
    	 expect(deck.facts).to be_empty
    end
  end
end
