require 'rails_helper'

RSpec.describe Users::Github::Organization, type: :model do
  it { is_expected.to have_many :followers }
end

# == Schema Information
#
# Table name: users_github_organizations
#
#  id                :integer          not null, primary key
#  login             :string(255)
#  company           :string(255)
#  blog              :string(255)
#  location          :string(255)
#  url               :string(255)
#  github_id         :integer
#  github_created_at :datetime
#  github_updated_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
