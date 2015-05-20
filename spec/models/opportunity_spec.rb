# == Schema Information
#
# Table name: opportunities
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  description      :text
#  designation      :string(255)
#  location         :string(255)
#  cached_tags      :string(255)
#  link             :string(255)
#  salary           :integer
#  options          :float
#  deleted          :boolean          default(FALSE)
#  deleted_at       :datetime
#  created_at       :datetime
#  updated_at       :datetime
#  expires_at       :datetime         default(1970-01-01 00:00:00 UTC)
#  opportunity_type :string(255)      default("full-time")
#  location_city    :string(255)
#  apply            :boolean          default(FALSE)
#  public_id        :string(255)
#  team_id          :integer
#  remote           :boolean
#

require 'spec_helper'

RSpec.describe Opportunity, type: :model do

  it 'should create a valid opportunity' do
    VCR.use_cassette('Opportunity') do
      tags = ['rails', 'sinatra', 'JQuery']
      opportunity = Fabricate(:opportunity, tag_list: tags)
      opportunity.save!
      expect(opportunity.name).not_to be_nil
      expect(opportunity.description).not_to be_nil
      expect(opportunity.team_id).not_to be_nil
      expect(opportunity.tags.size).to eq(tags.size)
      expect(opportunity.cached_tags).to eq(tags.map(&:downcase).join(','))
    end
  end

  describe 'destroying opportunity' do
    it 'should not destroy the opportunity and only lazy delete it' do
      VCR.use_cassette('Opportunity') do
        opportunity = Fabricate(:opportunity)
        opportunity.save
        expect(opportunity.deleted).to be_falsey
        opportunity.destroy
        expect(opportunity).to be_valid
        expect(opportunity.deleted).to be_truthy
        expect(opportunity.deleted_at).not_to be_nil
      end
    end
  end

  describe 'apply for job' do
    it 'should create a valid application' do
      VCR.use_cassette('Opportunity') do
        job = Fabricate(:opportunity)
        job.salary = 25_000
        user = Fabricate(:user)
        job.apply_for(user)
        expect(job.applicants.size).to eq(1)
        expect(job.applicants.first).to eq(user)
      end
    end

    it 'should not allow multiple applications' do
      VCR.use_cassette('Opportunity') do
        job = Fabricate(:opportunity)
        user = Fabricate(:user)
        expect(user.already_applied_for?(job)).to be_falsey
        expect(job.has_application_from?(user)).to be_falsey
        job.apply_for(user)
        user.apply_to(job)
        expect(job.applicants.size).to eq(1)
        expect(job.applicants.first).to eq(user)
        expect(user.already_applied_for?(job)).to be_truthy
        expect(job.has_application_from?(user)).to be_truthy
      end
    end
  end

  describe 'changing job location' do
    it 'should set location_city' do
      VCR.use_cassette('Opportunity') do
        job = Fabricate(:opportunity)
        expect(job.location_city.split('|')).to match_array(['San Francisco'])
        job.location = 'Amsterdam|San Francisco'
        job.save
        expect(job.location_city.split('|')).to match_array(['Amsterdam', 'San Francisco'])
      end
    end

    it 'should not add anywhere to location_city' do
			VCR.use_cassette('Opportunity') do
        job = Fabricate(:opportunity)
        job.location = 'Amsterdam|San Francisco|anywhere'
        job.save
        expect(job.location_city.split('|')).to match_array(['Amsterdam', 'San Francisco'])
      end
    end

    it 'should update location_city with changes' do
			VCR.use_cassette('Opportunity') do
        job = Fabricate(:opportunity)
        job.location = 'Amsterdam|San Francisco'
        job.save
        expect(job.location_city.split('|')).to match_array(['Amsterdam', 'San Francisco'])
        job.location = 'Amsterdam'
        job.save
        expect(job.location_city).to eq('Amsterdam')
      end
    end

    it 'should not add existing locations to the team' do
      VCR.use_cassette('Opportunity') do
        job = Fabricate(:opportunity)
        job.location = 'San Francisco'
        job.save
        expect(job.team.locations.count).to eq(1)
      end
    end
  end
end
