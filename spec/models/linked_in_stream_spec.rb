require 'spec_helper'

describe LinkedInStream, functional: true, pending: 'expected data has changed' do
  let(:username) { '3869d2ac-5293-4dfb-a9c7-926d84f7070c::01db0bce-cd44-4cbd-ac0e-24f3766a3083' }

  it 'should create events for work experiences and educataions' do
    linkedin = LinkedInStream.new(username)

    fact = linkedin.facts.first
    fact.identity.should == '205050716'
    fact.owner.should == "linkedin:#{username}"
    fact.name.should == "Software Developer at Highgroove"
    fact.url.should == 'http://www.linkedin.com/in/srbiv'
    fact.tags.should include("linkedin", "job")
    fact.relevant_on.to_date.should == Date.parse("2011-08-01")


    fact = linkedin.facts.last
    fact.identity.should == '15080101'
    fact.owner.should == "linkedin:#{username}"
    fact.name.should == "Studied Management at Georgia Institute of Technology"
    fact.url.should == 'http://www.linkedin.com/in/srbiv'
    fact.tags.should include("linkedin", "education")
    fact.relevant_on.to_date.should == Date.parse("1998/01/01")
  end
end
