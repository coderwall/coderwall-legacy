require 'spec_helper'

RSpec.describe PremiumHelper, :type => :helper do

  it 'should strip p tags from markdown' do
    expect(markdown("some raw text markdown")).to eq("some raw text markdown\n")
  end

end
