require 'spec_helper'

describe SpamReport do
  its(:spammable) { should be_nil }
end
