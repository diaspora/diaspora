require "spec_helper"

describe <%= controller_class_name %>Controller do
  describe "routing" do

<% unless options[:singleton] -%>
    it "routes to #index" do
      get("/<%= ns_table_name %>").should route_to("<%= ns_table_name %>#index")
    end

<% end -%>
    it "routes to #new" do
      get("/<%= ns_table_name %>/new").should route_to("<%= ns_table_name %>#new")
    end

    it "routes to #show" do
      get("/<%= ns_table_name %>/1").should route_to("<%= ns_table_name %>#show", :id => "1")
    end

    it "routes to #edit" do
      get("/<%= ns_table_name %>/1/edit").should route_to("<%= ns_table_name %>#edit", :id => "1")
    end

    it "routes to #create" do
      post("/<%= ns_table_name %>").should route_to("<%= ns_table_name %>#create")
    end

    it "routes to #update" do
      put("/<%= ns_table_name %>/1").should route_to("<%= ns_table_name %>#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/<%= ns_table_name %>/1").should route_to("<%= ns_table_name %>#destroy", :id => "1")
    end

  end
end
