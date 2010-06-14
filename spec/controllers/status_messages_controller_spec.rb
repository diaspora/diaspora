require File.dirname(__FILE__) + '/../spec_helper'
 
describe StatusMessagesController do
  fixtures :all
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
    delete :destroy, :id => status_message
    response.should redirect_to(status_messages_url)
    StatusMessage.exists?(status_message.id).should be_false
  end
  
  it "show action should render show template" do
    get :show, :id => StatusMessage.first
    response.should render_template(:show)
  end
end
