require File.dirname(__FILE__) + '/../spec_helper'
 
describe BlogsController do
  before do
    #TODO(dan) Mocking Warden; this is a temp fix
    request.env['warden'] = mock_model(Warden, :authenticate? => @user, :authenticate! => @user)
    User.create(:email => "bob@aol.com", :password => "secret")
    Blog.create(:title => "hello", :body => "sir")
  end

 render_views 
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    get :show, :id => Blog.first.id
    response.should render_template(:show)
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    Blog.any_instance.stubs(:valid?).returns(false)

    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    Blog.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(blog_url(assigns[:blog]))
  end
  
  it "edit action should render edit template" do
    get :edit, :id => Blog.first.id
    response.should render_template(:edit)
  end
  
  it "update action should render edit template when model is invalid" do
    Blog.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Blog.first.id
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    #TODO(dan) look into why we need to create a new bookmark object here
    Blog.any_instance.stubs(:valid?).returns(true)
    n = Blog.create

    put :update, :id => n.id
    response.should redirect_to(blog_url(assigns[:blog]))
  end
  
  it "destroy action should destroy model and redirect to index action" do
    blog = Blog.first
    delete :destroy, :id => blog.id
    response.should redirect_to(blogs_url)
    Blog.first(:conditions => {:id => blog.id }).nil?.should be true
  end
end
