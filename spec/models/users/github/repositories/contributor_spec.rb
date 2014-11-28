require 'rails_helper'

RSpec.describe Users::Github::Repositories::Contributor, type: :model do
  it { is_expected.to belong_to :profile }
  it { is_expected.to belong_to :repository }
end
