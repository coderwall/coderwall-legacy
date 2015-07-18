# == Schema Information
#
# Table name: networks
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  slug                :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  protips_count_cache :integer          default(0)
#  featured            :boolean          default(FALSE)
#  parent_id           :integer
#  network_tags        :citext           is an Array
#

require 'rails_helper'
require 'closure_tree/test/matcher'

RSpec.describe Network, type: :model do
  it { is_expected.to be_a_closure_tree.ordered(:name) }
end
