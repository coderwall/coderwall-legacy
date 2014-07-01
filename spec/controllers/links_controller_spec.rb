require 'spec_helper'

describe LinksController do

  describe "authorization" do
    let(:current_user) {user = Fabricate(:user, admin: false)}
    before { controller.send :sign_in, current_user }

    def valid_session
      {}
    end

    it "only allows admins on #index" do
      get :index, {}, valid_session
      expect(response.response_code).should == 403
    end

    it "only allows admins on #index" do
      get :suppress, {}, valid_session
      expect(response.response_code).should == 403
    end
  end

  

end
