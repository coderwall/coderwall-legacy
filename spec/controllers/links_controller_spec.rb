require 'spec_helper'

RSpec.describe LinksController, :type => :controller do

  describe "authorization" do
    let(:current_user) {Fabricate(:user, admin: false)}
    before { controller.send :sign_in, current_user }

    def valid_session
      {}
    end

    it "only allows admins on #index" do
      get :index, {}, valid_session
      expect(response.response_code).to eq(403)
    end

    it "only allows admins on #index" do
      get :suppress, {}, valid_session
      expect(response.response_code).to eq(403)
    end
  end

  

end
