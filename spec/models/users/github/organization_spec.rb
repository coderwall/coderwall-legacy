require 'rails_helper'

RSpec.describe Users::Github::Organization, type: :model do
  it { is_expected.to have_many :followers }
end
