require File.dirname(__FILE__) + '/../spec_helper'
 
describe StatusMessagesController do
  before do
    #TODO(dan) Mocking Warden; this is a temp fix
    request.env['warden'] = mock_model(Warden, :authenticate => @user, :authenticate! => @user)
    StatusMessage.create(:message => "yodels.")
  end

  #fixtures :all
  render_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "create action should render new template when model is invalid" do
    StatusMessage.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    StatusMessage.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(status_message_url(assigns[:status_message]))
  end
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "destroy action should destroy model and redirect to index action" do
    status_message = StatusMessage.first
    delete :destroy, :id => status_message.id
    response.should redirect_to(status_messages_url)
    StatusMessage.first(:conditions => {:id => status_message.id }).nil?.should be true
  end
  
  it "show action should render show template" do
    get :show, :id => StatusMessage.first.id
    response.should render_template(:show)
  end
end
