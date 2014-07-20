# == Schema Information
#
# Table name: teams
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe PgTeam, :type => :model do
  it {is_expected.to have_one :account}

  it {is_expected.to have_many :locations}
  it {is_expected.to have_many :links}
  it {is_expected.to have_many :members}
  it {is_expected.to have_many :jobs}
end
