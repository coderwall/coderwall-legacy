require 'spec_helper'

RSpec.describe Endorsement, :type => :model do

  it 'requires a specialty' do
    endorsement = Fabricate.build(:endorsement, specialty: nil)
    expect(endorsement).not_to be_valid
  end

  it 'requires an endorsed user' do
    endorsement = Fabricate.build(:endorsement, endorsed: nil)
    expect(endorsement).not_to be_valid
  end

  it 'requires an endorsing user' do
    endorsement = Fabricate.build(:endorsement, endorser: nil)
    expect(endorsement).not_to be_valid
  end

  it 'udates the users updated_at timestamp when they recieve a new endorsement' do
    endorsed = Fabricate(:user)
    original_updated_at = endorsed.updated_at
    Fabricate(:user).endorse(endorsed, 'skill')
    endorsed.reload
    expect(endorsed.updated_at).not_to eq(original_updated_at)
  end

  describe User do
    let(:endorser) { Fabricate(:user) }
    let(:endorsed) {
      user = Fabricate(:user, username: 'somethingelse')
      endorser.endorse(user, 'ruby')
      user
    }

    it 'saves the specialty' do
      expect(endorsed.endorsements.first.specialty).to eq('ruby')
    end

    it 'saves the endorsed' do
      expect(endorsed.endorsements.first.endorsed).to eq(endorsed)
    end

    it 'saves the endorser' do
      endorsed.reload
      expect(endorsed.endorsements.size).to eq(1)
      expect(endorsed.endorsements.first.endorser).to eq(endorser)
    end

    class NotaBadge < BadgeBase
    end

    it 'should increment counter cache' do
      endorsed.reload
      expect(endorsed.endorsements_count).to eq(1)
    end
  end

end

# == Schema Information
# Schema version: 20140918031936
#
# Table name: endorsements
#
#  id                :integer          not null, primary key
#  endorsed_user_id  :integer
#  endorsing_user_id :integer
#  specialty         :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  skill_id          :integer
#
