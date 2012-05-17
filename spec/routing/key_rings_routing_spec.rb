require "spec_helper"

describe KeyRingsController do
  describe "routing" do

    it "routes to #index" do
      get("/key_rings").should route_to("key_rings#index")
    end

    it "routes to #new" do
      get("/key_rings/new").should route_to("key_rings#new")
    end

    it "routes to #show" do
      get("/key_rings/1").should route_to("key_rings#show", :id => "1")
    end

    it "routes to #edit" do
      get("/key_rings/1/edit").should route_to("key_rings#edit", :id => "1")
    end

    it "routes to #create" do
      post("/key_rings").should route_to("key_rings#create")
    end

    it "routes to #update" do
      put("/key_rings/1").should route_to("key_rings#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/key_rings/1").should route_to("key_rings#destroy", :id => "1")
    end

  end
end
