require 'rails_helper'
require 'closure_tree/test/matcher'

RSpec.describe NetworksController, type: :controller do
  pending 'Add tests for join and leave'

  it { is_expected.to be_a_closure_tree.ordered(:name) }
end
