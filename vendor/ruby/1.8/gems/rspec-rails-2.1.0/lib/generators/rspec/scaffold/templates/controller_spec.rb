require 'spec_helper'

describe <%= controller_class_name %>Controller do

  def <%= mock_file_name %>(stubs={})
    (@<%= mock_file_name %> ||= mock_model(<%= class_name %>).as_null_object).tap do |<%= file_name %>|
      <%= file_name %>.stub(stubs) unless stubs.empty?
    end
  end

<% unless options[:singleton] -%>
  describe "GET index" do
    it "assigns all <%= table_name.pluralize %> as @<%= table_name.pluralize %>" do
      <%= stub! orm_class.all(class_name) %> { [<%= mock_file_name %>] }
      get :index
      assigns(:<%= table_name %>).should eq([<%= mock_file_name %>])
    end
  end

<% end -%>
  describe "GET show" do
    it "assigns the requested <%= file_name %> as @<%= file_name %>" do
      <%= stub! orm_class.find(class_name, "37".inspect) %> { <%= mock_file_name %> }
      get :show, :id => "37"
      assigns(:<%= file_name %>).should be(<%= mock_file_name %>)
    end
  end

  describe "GET new" do
    it "assigns a new <%= file_name %> as @<%= file_name %>" do
      <%= stub! orm_class.build(class_name) %> { <%= mock_file_name %> }
      get :new
      assigns(:<%= file_name %>).should be(<%= mock_file_name %>)
    end
  end

  describe "GET edit" do
    it "assigns the requested <%= file_name %> as @<%= file_name %>" do
      <%= stub! orm_class.find(class_name, "37".inspect) %> { <%= mock_file_name %> }
      get :edit, :id => "37"
      assigns(:<%= file_name %>).should be(<%= mock_file_name %>)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created <%= file_name %> as @<%= file_name %>" do
        <%= stub! orm_class.build(class_name, params) %> { <%= mock_file_name(:save => true) %> }
        post :create, :<%= file_name %> => <%= params %>
        assigns(:<%= file_name %>).should be(<%= mock_file_name %>)
      end

      it "redirects to the created <%= file_name %>" do
        <%= stub! orm_class.build(class_name) %> { <%= mock_file_name(:save => true) %> }
        post :create, :<%= file_name %> => {}
        response.should redirect_to(<%= table_name.singularize %>_url(<%= mock_file_name %>))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved <%= file_name %> as @<%= file_name %>" do
        <%= stub! orm_class.build(class_name, params) %> { <%= mock_file_name(:save => false) %> }
        post :create, :<%= file_name %> => <%= params %>
        assigns(:<%= file_name %>).should be(<%= mock_file_name %>)
      end

      it "re-renders the 'new' template" do
        <%= stub! orm_class.build(class_name) %> { <%= mock_file_name(:save => false) %> }
        post :create, :<%= file_name %> => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested <%= file_name %>" do
        <%= should_receive! orm_class.find(class_name, "37".inspect) %> { <%= mock_file_name %> }
        mock_<%= should_receive! orm_instance.update_attributes(params) %>
        put :update, :id => "37", :<%= file_name %> => <%= params %>
      end

      it "assigns the requested <%= file_name %> as @<%= file_name %>" do
        <%= stub! orm_class.find(class_name) %> { <%= mock_file_name(:update_attributes => true) %> }
        put :update, :id => "1"
        assigns(:<%= file_name %>).should be(<%= mock_file_name %>)
      end

      it "redirects to the <%= file_name %>" do
        <%= stub! orm_class.find(class_name) %> { <%= mock_file_name(:update_attributes => true) %> }
        put :update, :id => "1"
        response.should redirect_to(<%= table_name.singularize %>_url(<%= mock_file_name %>))
      end
    end

    describe "with invalid params" do
      it "assigns the <%= file_name %> as @<%= file_name %>" do
        <%= stub! orm_class.find(class_name) %> { <%= mock_file_name(:update_attributes => false) %> }
        put :update, :id => "1"
        assigns(:<%= file_name %>).should be(<%= mock_file_name %>)
      end

      it "re-renders the 'edit' template" do
        <%= stub! orm_class.find(class_name) %> { <%= mock_file_name(:update_attributes => false) %> }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested <%= file_name %>" do
      <%= should_receive! orm_class.find(class_name, "37".inspect) %> { <%= mock_file_name %> }
      mock_<%= should_receive! orm_instance.destroy %>
      delete :destroy, :id => "37"
    end

    it "redirects to the <%= table_name %> list" do
      <%= stub! orm_class.find(class_name) %> { <%= mock_file_name %> }
      delete :destroy, :id => "1"
      response.should redirect_to(<%= table_name %>_url)
    end
  end

end
