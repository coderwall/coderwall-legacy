RSpec.describe UnbansController, type: :controller do

  def valid_session
    {}
  end

  describe 'POST create' do

    it_behaves_like 'admin controller with #create'

    it 'bans a user', skip: true do
      user = Fabricate(:user, admin: true, banned_at: Time.now)
      expect(user.reload.banned?).to eq(true)

      controller.send :sign_in, user
      post :create, { user_id: user.id }, valid_session

      expect(user.reload.banned?).to eq(false)
    end
  end

end
