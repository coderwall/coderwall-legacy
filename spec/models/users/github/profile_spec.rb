require 'rails_helper'

RSpec.describe Users::Github::Profile, :type => :model do
  it {is_expected.to belong_to :user}
  it {is_expected.to have_many :followers}
  it {is_expected.to have_many :repositories}
end
