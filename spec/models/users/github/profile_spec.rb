require 'rails_helper'

RSpec.describe Users::Github::Profile, :type => :model do
  it {is_expected.to belong_to :user}
  it {is_expected.to have_many :followers}
  it {is_expected.to have_many :repositories}
end

# == Schema Information
# Schema version: 20140728214411
#
# Table name: users_github_profiles
#
#  id         :integer          not null, primary key
#  login      :string(255)
#  name       :string(255)
#  company    :string(255)
#  location   :string(255)
#  github_id  :integer          not null
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
