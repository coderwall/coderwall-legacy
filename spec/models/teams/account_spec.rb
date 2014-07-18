require 'rails_helper'

RSpec.describe Teams::Account, :type => :model do
  it {is_expected.to belong_to(:team)}
end
