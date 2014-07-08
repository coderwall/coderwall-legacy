require 'spec_helper'

describe Comment do
  its(:spam_report) { should be_nil }
end
