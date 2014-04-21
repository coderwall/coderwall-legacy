# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `endorsements`
#
# ### Columns
#
# Name                     | Type               | Attributes
# ------------------------ | ------------------ | ---------------------------
# **`created_at`**         | `datetime`         |
# **`endorsed_user_id`**   | `integer`          |
# **`endorsing_user_id`**  | `integer`          |
# **`id`**                 | `integer`          | `not null, primary key`
# **`skill_id`**           | `integer`          |
# **`specialty`**          | `string(255)`      |
# **`updated_at`**         | `datetime`         |
#
# ### Indexes
#
# * `index_endorsements_on_endorsed_user_id`:
#     * **`endorsed_user_id`**
# * `index_endorsements_on_endorsing_user_id`:
#     * **`endorsing_user_id`**
# * `only_unique_endorsements` (_unique_):
#     * **`endorsed_user_id`**
#     * **`endorsing_user_id`**
#     * **`specialty`**
#

require 'spec_helper'

describe Endorsement do

  it 'requires a specialty' do
    endorsement = Fabricate.build(:endorsement, specialty: nil)
    endorsement.should_not be_valid
  end

  it 'requires an endorsed user' do
    endorsement = Fabricate.build(:endorsement, endorsed: nil)
    endorsement.should_not be_valid
  end

  it 'requires an endorsing user' do
    endorsement = Fabricate.build(:endorsement, endorser: nil)
    endorsement.should_not be_valid
  end

  it 'udates the users updated_at timestamp when they recieve a new endorsement' do
    endorsed = Fabricate(:user)
    original_updated_at = endorsed.updated_at
    Fabricate(:user).endorse(endorsed, 'skill')
    endorsed.reload
    endorsed.updated_at.should_not == original_updated_at
  end

  describe User do
    let(:endorser) { Fabricate(:user) }
    let(:endorsed) {
      user = Fabricate(:user, username: 'somethingelse')
      endorser.endorse(user, 'ruby')
      user
    }

    it 'saves the specialty' do
      endorsed.endorsements.first.specialty.should == 'ruby'
    end

    it 'saves the endorsed' do
      endorsed.endorsements.first.endorsed.should == endorsed
    end

    it 'saves the endorser' do
      endorsed.reload
      endorsed.endorsements.size.should == 1
      endorsed.endorsements.first.endorser.should == endorser
    end

    class NotaBadge < BadgeBase
    end

    it 'should increment counter cache' do
      endorsed.reload
      endorsed.endorsements_count.should == 1
    end
  end

end
