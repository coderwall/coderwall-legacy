shared_examples "admin controller with #create" do

  it "only allows admins on #create" do
    user = Fabricate(:user)
    controller.send :sign_in, user
    post :create, {}, {}
    expect(response.response_code).to eq(403)
  end
end
