require 'rails_helper'

RSpec.describe Teams::Member, :type => :model do
  it {is_expected.to belong_to(:team).counter_cache(:team_size)}
  it {is_expected.to belong_to(:user)}
end
