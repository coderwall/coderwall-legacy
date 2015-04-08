require 'spec_helper'

RSpec.describe OpportunitiesController, type: :controller do

  describe "GET index" do
    it "should respond with 200" do
      get :index
      expect(response.status).to eq(200)
    end

    it "should render the opportunities index template with jobs layout" do
      get :index
      expect(response).to render_template(['opportunities/index', 'layouts/jobs'])
    end

    context "when it's filtered" do
      context "by remote opportunities" do
        before(:all) { @opportunity1 = Fabricate(:opportunity, remote: true, location: "Anywhere") }

        it "should assign the remote opportunities to @jobs" do
          get :index, location: nil, remote: 'true'
          expect(assigns(:jobs)).to be_include(@opportunity1)
        end
      end

      context "by query" do
        before(:all) { @opportunity2 = Fabricate(:opportunity, remote: true, location: "Anywhere", location_city: "San Francisco") }

        it "should assign the remote opportunities to @jobs which have the keyword 'senior rails' [attr: name]" do
          get :index, location: nil, q: 'senior rails'
          expect(assigns(:jobs)).to be_include(@opportunity2)
        end

        it "should assign the remote opportunities to @jobs which have the keyword 'underpinnings' [attr: description]" do
          get :index, location: nil, q: 'underpinnings'
          expect(assigns(:jobs)).to be_include(@opportunity2)
        end

        it "should assign the remote opportunities to @jobs which have the keyword 'jquery' [attr: tag]" do
          get :index, location: nil, q: 'jquery'
          expect(assigns(:jobs)).to be_include(@opportunity2)
        end

        it "should NOT assign the remote opportunities to @jobs which have the keyword dev-ops" do
          get :index, location: nil, q: 'dev-ops'
          expect(assigns(:jobs)).to_not be_include(@opportunity2)
        end
      end

      context "by query with keywords containing regexp special characters" do
        it "should NOT fail when querying with keywords containing '+'" do
          get :index, location: nil, q: 'C++'
          expect(assigns(:jobs))
        end
        it "should NOT fail when querying with keywords containing '.^$*+?()[{\|'" do
          get :index, location: nil, q: 'java .^$*+?()[{\|'
          expect(assigns(:jobs))
        end
      end
    end
  end
end
