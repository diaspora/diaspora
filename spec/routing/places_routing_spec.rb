require "spec_helper"

describe PlacesController do
  describe "routing" do

    it "routes to #index" do
      get("/places").should route_to("places#index")
    end

    it "routes to #new" do
      get("/places/new").should route_to("places#new")
    end

    it "routes to #show" do
      get("/places/1").should route_to("places#show", :id => "1")
    end

    it "routes to #edit" do
      get("/places/1/edit").should route_to("places#edit", :id => "1")
    end

    it "routes to #create" do
      post("/places").should route_to("places#create")
    end

    it "routes to #update" do
      put("/places/1").should route_to("places#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/places/1").should route_to("places#destroy", :id => "1")
    end

  end
end
