require File.dirname(__FILE__) + '/../spec_helper'
 
describe BookmarksController do
  before do
    #TODO(dan) Mocking Warden; this is a temp fix
    request.env['warden'] = mock_model(Warden, :authenticate? => @user, :authenticate! => @user)
    @bob = Factory.build(:user)
    @bookmark = Factory.build(:bookmark) 
    @bob.save
    @bookmark.save
  end

  render_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "edit action should render edit template" do
    get :edit, :id => Bookmark.first.id
    response.should render_template(:edit)
  end
  
  it "update action should render edit template when model is invalid" do
    Bookmark.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Bookmark.first.id
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    #TODO(dan) look into why we need to create a new bookmark object here
    Bookmark.any_instance.stubs(:valid?).returns(true)
    n = Factory.create(:bookmark, :link => "http://hotub.com")
    n.save 
    put :update, :id => Bookmark.first.id
    response.should redirect_to(bookmark_url(assigns[:bookmark]))
  end
  
  it "show action should render show template" do
    get :show, :id => Bookmark.first.id
    response.should render_template(:show)
  end
  
  it "create action should render new template when model is invalid" do
    Bookmark.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    Bookmark.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(bookmark_url(assigns[:bookmark]))
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "destroy action should destroy model and redirect to index action" do
    bookmark = Bookmark.first
    delete :destroy, :id => bookmark.id
    response.should redirect_to(bookmarks_url)
    Bookmark.first(:conditions => {:id => bookmark.id }).nil?.should be true
  end
end
