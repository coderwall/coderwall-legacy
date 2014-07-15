require 'spec_helper'

RSpec.describe Opportunity, type: :model do
  # before(:each) do
  # FakeWeb.register_uri(:get, 'http://maps.googleapis.com/maps/api/geocode/json?address=San+Francisco%2C+CA&language=en&sensor=false', body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'google_maps.json')))
  # end

  describe 'creating and validating a new opportunity' do
    it 'should create a valid opportunity' do
      tags = ['rails', 'sinatra', 'JQuery', 'Clean, beautiful code']
      opportunity = Fabricate(:opportunity, tags: tags)
      opportunity.save!
      expect(opportunity.name).not_to be_nil
      expect(opportunity.description).not_to be_nil
      expect(opportunity.team_document_id).not_to be_nil
      expect(opportunity.tags.size).to eq(tags.size)
      expect(opportunity.cached_tags).to eq(tags.join(','))
    end

    it 'can create opportunity with no tags without error' do
      skip 'need to upgrade to latest rocket tag'
      expect { Fabricate(:opportunity, tags: '') }.not_to raise_error
    end
  end

  describe 'destroying opportunity' do
    it 'should not destroy the opportunity and only lazy delete it' do
      opportunity = Fabricate(:opportunity)
      opportunity.save
      expect(opportunity.deleted).to be_falsey
      opportunity.destroy
      expect(opportunity).to be_valid
      expect(opportunity.deleted).to be_truthy
      expect(opportunity.deleted_at).not_to be_nil
    end
  end

  describe 'parse job salary' do
    it 'should parse salaries correctly' do
      salary = Opportunity.parse_salary('100000')
      expect(salary).to eq(100_000)
      salary = Opportunity.parse_salary('100')
      expect(salary).to eq(100_000)
      salary = Opportunity.parse_salary('100k')
      expect(salary).to eq(100_000)
      salary = Opportunity.parse_salary('100 K')
      expect(salary).to eq(100_000)
    end
  end

  describe 'apply for job' do
    it 'should create a valid application' do
      job = Fabricate(:job)
      job.salary = 25_000
      user = Fabricate(:user)
      job.apply_for(user)
      expect(job.applicants.size).to eq(1)
      expect(job.applicants.first).to eq(user)
    end

    it 'should not allow multiple applications' do
      job = Fabricate(:job)
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

  describe 'changing job location' do
    it 'should set location_city' do
      job = Fabricate(:job)
      job.location = 'Amsterdam|San Francisco'
      job.save
      expect(job.location_city.split('|') - ['Amsterdam', 'San Francisco']).to eq([])
    end

    it 'should not add anywhere to location_city' do
      job = Fabricate(:job)
      job.location = 'Amsterdam|San Francisco|anywhere'
      job.save
      expect(job.location_city.split('|') - ['Amsterdam', 'San Francisco']).to eq([])
    end

    it 'should update location_city with changes' do
      job = Fabricate(:job)
      job.location = 'Amsterdam|San Francisco'
      job.save
      expect(job.location_city.split('|') - ['Amsterdam', 'San Francisco']).to eq([])
      job.location = 'Amsterdam'
      job.save
      expect(job.location_city).to eq('Amsterdam')
    end

    it 'should not add existing locations to the team' do
      job = Fabricate(:job)
      job.location = 'San Francisco'
      job.save
      expect(job.team.team_locations.count).to be === 1
    end
  end
end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: opportunities
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  description      :text
#  designation      :string(255)
#  location         :string(255)
#  cached_tags      :string(255)
#  team_document_id :string(255)
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
#
