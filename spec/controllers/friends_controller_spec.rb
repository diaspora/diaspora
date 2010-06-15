require File.dirname(__FILE__) + '/../spec_helper'
 
describe FriendsController do
  render_views
  before do
    #TODO(dan) Mocking Warden; this is a temp fix
    request.env['warden'] = mock_model(Warden, :authenticate => @user, :authenticate! => @user)
    @friend = Factory.build(:friend)
  end
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "show action should render show template" do
    @friend.save
    request.env['warden'].should_receive(:authenticate?).at_least(:once)
    get :show, :id => @friend.id
    response.should render_template(:show)
  end
  
  it "destroy action should destroy model and redirect to index action" do
    @friend.save
    delete :destroy, :id => @friend.id
    response.should redirect_to(friends_url)
    Friend.first(:conditions => {:id => @friend.id}).should be_nil
  end
   
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    Friend.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    Friend.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(friend_url(assigns[:friend]))
  end
  
  it 'should test that a real creation adds to the database' do 
  end
  
  it 'should have test that a delete removes a friend from the database' do
  end
  
end
