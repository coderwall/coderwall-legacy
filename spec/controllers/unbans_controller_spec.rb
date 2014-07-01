describe UnbansController do

  def valid_session
    {}
  end

  describe "POST create" do

    it_behaves_like "admin controller with #create"

    it "bans a user" do
      user = Fabricate(:user, admin: true, banned_at: Time.now)
      user.reload.banned?.should == true

      controller.send :sign_in, user
      post :create, {user_id: user.id}, valid_session

      user.reload.banned?.should == false
    end
  end

end
