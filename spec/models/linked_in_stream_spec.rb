require 'spec_helper'

RSpec.describe LinkedInStream, type: :model, functional: true, pending: 'expected data has changed' do
  let(:username) { '3869d2ac-5293-4dfb-a9c7-926d84f7070c::01db0bce-cd44-4cbd-ac0e-24f3766a3083' }

  it 'should create events for work experiences and educataions' do
    linkedin = LinkedInStream.new(username)

    fact = linkedin.facts.first
    expect(fact.identity).to eq('205050716')
    expect(fact.owner).to eq("linkedin:#{username}")
    expect(fact.name).to eq("Software Developer at Highgroove")
    expect(fact.url).to eq('http://www.linkedin.com/in/srbiv')
    expect(fact.tags).to include("linkedin", "job")
    expect(fact.relevant_on.to_date).to eq(Date.parse("2011-08-01"))


    fact = linkedin.facts.last
    expect(fact.identity).to eq('15080101')
    expect(fact.owner).to eq("linkedin:#{username}")
    expect(fact.name).to eq("Studied Management at Georgia Institute of Technology")
    expect(fact.url).to eq('http://www.linkedin.com/in/srbiv')
    expect(fact.tags).to include("linkedin", "education")
    expect(fact.relevant_on.to_date).to eq(Date.parse("1998/01/01"))
  end
end
