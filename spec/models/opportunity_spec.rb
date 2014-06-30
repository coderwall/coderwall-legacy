# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `opportunities`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`apply`**             | `boolean`          | `default(FALSE)`
# **`cached_tags`**       | `string(255)`      |
# **`created_at`**        | `datetime`         |
# **`deleted`**           | `boolean`          | `default(FALSE)`
# **`deleted_at`**        | `datetime`         |
# **`description`**       | `text`             |
# **`designation`**       | `string(255)`      |
# **`expires_at`**        | `datetime`         | `default(1970-01-01 00:00:00 UTC)`
# **`id`**                | `integer`          | `not null, primary key`
# **`link`**              | `string(255)`      |
# **`location`**          | `string(255)`      |
# **`location_city`**     | `string(255)`      |
# **`name`**              | `string(255)`      |
# **`opportunity_type`**  | `string(255)`      | `default("full-time")`
# **`options`**           | `float`            |
# **`public_id`**         | `string(255)`      |
# **`salary`**            | `integer`          |
# **`team_document_id`**  | `string(255)`      |
# **`updated_at`**        | `datetime`         |
#

require 'spec_helper'

describe Opportunity do
  #before(:each) do
    #FakeWeb.register_uri(:get, 'http://maps.googleapis.com/maps/api/geocode/json?address=San+Francisco%2C+CA&language=en&sensor=false', body: File.read(File.join(Rails.root, 'spec', 'fixtures', 'google_maps.json')))
  #end

  describe "creating and validating a new opportunity" do
    it "should create a valid opportunity" do
      tags = ["rails", "sinatra", "JQuery", "Clean, beautiful code"]
      opportunity = Fabricate(:opportunity, tags: tags)
      opportunity.save!
      opportunity.name.should_not be_nil
      opportunity.description.should_not be_nil
      opportunity.team_document_id.should_not be_nil
      opportunity.tags.size.should == tags.size
      opportunity.cached_tags.should == tags.join(",")
    end

    it 'can create opportunity with no tags without error' do
      pending "need to upgrade to latest rocket tag"
      lambda { Fabricate(:opportunity, tags: "") }.should_not raise_error
    end
  end

  describe "destroying opportunity" do
    it "should not destroy the opportunity and only lazy delete it" do
      opportunity = Fabricate(:opportunity)
      opportunity.save
      opportunity.deleted.should be_false
      opportunity.destroy
      opportunity.should be_valid
      opportunity.deleted.should be_true
      opportunity.deleted_at.should_not be_nil
    end
  end

  describe "parse job salary" do
    it "should parse salaries correctly" do
      salary = Opportunity.parse_salary("100000")
      salary.should == 100000
      salary = Opportunity.parse_salary("100")
      salary.should == 100000
      salary = Opportunity.parse_salary("100k")
      salary.should == 100000
      salary = Opportunity.parse_salary("100 K")
      salary.should == 100000
    end
  end

  describe "apply for job" do
    it "should create a valid application" do
      job = Fabricate(:job)
      job.salary = 25000
      user = Fabricate(:user)
      job.apply_for(user)
      job.applicants.size.should == 1
      job.applicants.first.should == user
    end

    it "should not allow multiple applications" do
      job = Fabricate(:job)
      user = Fabricate(:user)
      user.already_applied_for?(job).should be_false
      job.has_application_from?(user).should be_false
      job.apply_for(user)
      user.apply_to(job)
      job.applicants.size.should == 1
      job.applicants.first.should == user
      user.already_applied_for?(job).should be_true
      job.has_application_from?(user).should be_true
    end
  end

  describe "changing job location" do
    it "should set location_city" do
      job = Fabricate(:job)
      job.location = "Amsterdam|San Francisco"
      job.save
      (job.location_city.split("|") - ["Amsterdam", "San Francisco"]).should == []
    end

    it "should not add anywhere to location_city" do
      job = Fabricate(:job)
      job.location = "Amsterdam|San Francisco|anywhere"
      job.save
      (job.location_city.split("|") - ["Amsterdam", "San Francisco"]).should == []
    end

    it "should update location_city with changes" do
      job = Fabricate(:job)
      job.location = "Amsterdam|San Francisco"
      job.save
      (job.location_city.split("|") - ["Amsterdam", "San Francisco"]).should == []
      job.location = "Amsterdam"
      job.save
      job.location_city.should == "Amsterdam"
    end

    it "should not add existing locations to the team" do
      job = Fabricate(:job)
      job.location = "San Francisco"
      job.save
      job.team.team_locations.count.should === 1
    end
  end
end
