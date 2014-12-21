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
  end
end
