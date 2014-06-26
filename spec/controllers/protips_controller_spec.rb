describe ProtipsController do
  let(:current_user) { Fabricate(:user) }

  before { controller.send :sign_in, current_user }

  def valid_attributes
    {
        title: "hello world",
        body: "somethings that's meaningful and nice",
        topics: ["java", "javascript"],
        user_id: current_user.id
    }
  end

  def valid_session
    {}
  end

  describe "GET topic" do
    it "assigns all protips as @protips" do
      Protip.rebuild_index
      protip = Protip.create! valid_attributes
      get :topic, {tags: "java"}, valid_session
      assigns(:protips).results.first.title.should eq(protip.title)
    end
  end

  describe "GET show" do
    it "assigns the requested protip as @protip" do
      protip = Protip.create! valid_attributes
      get :show, {id: protip.to_param}, valid_session
      assigns(:protip).should eq(protip)
    end
  end

  describe "GET new" do
    before { User.any_instance.stub(:skills).and_return(['skill']) } # User must have a skill to create protips

    it "assigns a new protip as @protip" do
      get :new, {}, valid_session
      assigns(:protip).should be_a_new(Protip)
    end

    it "allows viewing the page when you have a skill" do
      get :new, {}, valid_session
      response.should render_template('new')
    end

    it "prevents viewing the page when you don't have a skill" do
      User.any_instance.stub(:skills).and_return([])
      get :new, {}, valid_session
      response.should redirect_to badge_path(username: current_user.username, anchor: 'add-skill')
    end
  end

  describe "GET edit" do
    it "assigns the requested protip as @protip" do
      protip = Protip.create! valid_attributes
      get :edit, {id: protip.to_param}, valid_session
      assigns(:protip).should eq(protip)
    end
  end

  describe "POST create" do
    before { User.any_instance.stub(:skills).and_return(['skill']) } # User must have a skill to create protips

    describe "with valid params" do
      it "creates a new Protip" do
        expect {
          post :create, {protip: valid_attributes}, valid_session
        }.to change(Protip, :count).by(1)
      end

      it "assigns a newly created protip as @protip" do
        post :create, {protip: valid_attributes}, valid_session
        assigns(:protip).should be_a(Protip)
        assigns(:protip).should be_persisted
      end

      it "redirects to the created protip" do
        post :create, { protip: valid_attributes }, valid_session
        response.should redirect_to(Protip.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved protip as @protip" do
        # Trigger the behavior that occurs when invalid params are submitted
        Protip.any_instance.stub(:save).and_return(false)
        post :create, {protip: {}}, valid_session
        assigns(:protip).should be_a_new(Protip)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Protip.any_instance.stub(:save).and_return(false)
        post :create, { protip: {} }, valid_session
        response.should render_template("new")
      end
    end

    it "prevents creating when you don't have a skill" do
      User.any_instance.stub(:skills).and_return([])
      post :create, {protip: valid_attributes}, valid_session
      response.should redirect_to badge_path(username: current_user.username, anchor: 'add-skill')
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested protip" do
        protip = Protip.create! valid_attributes
        # Assuming there are no other protips in the database, this
        # specifies that the Protip created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Protip.any_instance.should_receive(:update_attributes).with({'body' => 'params'})
        put :update, {id: protip.to_param, protip: {'body' => 'params'}}, valid_session
      end

      it "assigns the requested protip as @protip" do
        protip = Protip.create! valid_attributes
        put :update, {id: protip.to_param, protip: valid_attributes}, valid_session
        assigns(:protip).should eq(protip)
      end

      it "redirects to the protip" do
        protip = Protip.create! valid_attributes
        put :update, {id: protip.to_param, protip: valid_attributes}, valid_session
        response.should redirect_to(protip)
      end
    end

    describe "with invalid params" do
      it "assigns the protip as @protip" do
        protip = Protip.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Protip.any_instance.stub(:save).and_return(false)
        put :update, {id: protip.to_param, protip: {}}, valid_session
        assigns(:protip).should eq(protip)
      end

      it "re-renders the 'edit' template" do

        protip = Protip.create!(valid_attributes)
        # Trigger the behavior that occurs when invalid params are submitted
        Protip.any_instance.stub(:save).and_return(false)

        put :update, { id: protip.to_param, protip: {} }, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "returns forbidden if current user not owner" do
      attributes = valid_attributes
      attributes[:user_id] = Fabricate(:user).id
      protip = Protip.create! attributes
      delete :destroy, {id: protip.to_param}, valid_session
      lambda { protip.reload }.should_not raise_error
    end

    it "destroys the requested protip" do
      protip = Protip.create! valid_attributes
      expect {
        delete :destroy, {id: protip.to_param}, valid_session
      }.to change(Protip, :count).by(-1)
    end

    it 'redirects to the protips list' do
      protip = Protip.create!(valid_attributes)
      delete :destroy, {id: protip.to_param}, valid_session
      response.should redirect_to(protips_url)
    end
  end

end
