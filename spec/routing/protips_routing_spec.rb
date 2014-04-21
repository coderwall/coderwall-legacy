describe ProtipsController do
  describe "routing" do

    it "routes to #topic" do
      get("/p/t").should route_to("networks#tag")
    end

    it "routes to #new" do
      get("/p/new").should route_to("protips#new")
    end

    it "routes to #show" do
      get("/p/hazc5q").should route_to("protips#show", id: "hazc5q")
    end

    it "routes to #edit" do
      get("/p/hazc5q/edit").should route_to("protips#edit", id: "hazc5q")
    end

    it "routes to #create" do
      post("/p").should route_to("protips#create")
    end

    it "routes to #update" do
      put("/p/hazc5q").should route_to("protips#update", id: "hazc5q")
    end

  end
end
