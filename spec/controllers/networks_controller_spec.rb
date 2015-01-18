RSpec.describe NetworksController, type: :controller do
  let(:current_user) { Fabricate(:user, admin: true) }

  before { controller.send :sign_in, current_user }

  def valid_attributes
    {
      name: 'python'
    }
  end

  def valid_session
    {}
  end

  describe 'Create network' do
    describe 'with valid attributes' do
      it 'creates a network and adds to tags' do
        expect do
          post :create, { network: valid_attributes}, valid_session
        end.to change(Tag, :count).by(1)
      end
    end
  end
end
