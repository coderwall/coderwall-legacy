# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `badges`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`badge_class_name`**  | `string(255)`      |
# **`created_at`**        | `datetime`         |
# **`id`**                | `integer`          | `not null, primary key`
# **`updated_at`**        | `datetime`         |
# **`user_id`**           | `integer`          |
#
# ### Indexes
#
# * `index_badges_on_user_id`:
#     * **`user_id`**
# * `index_badges_on_user_id_and_badge_class_name` (_unique_):
#     * **`user_id`**
#     * **`badge_class_name`**
#

require 'spec_helper'

RSpec.describe Badge, :type => :model do
  let(:badge) { Badge.new(badge_class_name: 'Polygamous') }

  it 'gets name from badge class' do
    expect(badge.display_name).to eq('Walrus')
  end

  it 'gets description from badge class' do
    expect(badge.description).to include('The walrus is no stranger')
  end

  it 'creates an image path from image name in class' do
    expect(badge.image_path).to eq('badges/walrus.png')
  end

end
