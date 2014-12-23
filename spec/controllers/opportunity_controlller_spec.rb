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

    context "when it's filtered by remote opportunities" do
      before { @opportunity = Fabricate(:opportunity, remote: true, location: "Anywhere") }

      it "should assign the remote opportunities to @jobs" do
        get :index, location: 'remote'
        expect(assigns(:jobs)).to be_include(@opportunity)
      end
    end
  end
end
