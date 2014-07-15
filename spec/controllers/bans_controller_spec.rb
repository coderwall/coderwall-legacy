RSpec.describe BansController, type: :controller do

  def valid_session
    {}
  end

  describe 'POST create' do

   it_behaves_like 'admin controller with #create'

   it 'bans a user' do
     user = Fabricate(:user, admin: true)
     controller.send :sign_in, user
     post :create, { user_id: user.id }, valid_session

     expect(user.reload.banned?).to eq(true)
   end
 end

end
