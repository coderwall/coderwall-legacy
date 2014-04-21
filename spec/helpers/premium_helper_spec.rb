require 'spec_helper'

describe PremiumHelper do

  it 'should strip p tags from markdown' do
    markdown("some raw text markdown").should == "some raw text markdown\n"
  end

end
