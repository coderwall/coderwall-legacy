require 'rails_helper'

RSpec.describe Users::Github::Repository, :type => :model do
  it { is_expected.to have_many :followers }
  it { is_expected.to belong_to :organization }
  it { is_expected.to belong_to :owner }
end
