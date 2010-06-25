require File.dirname(__FILE__) + '/../spec_helper'
 
describe StatusMessagesController do
  before do
    #TODO(dan) Mocking Warden; this is a temp fix
    request.env['warden'] = mock_model(Warden, :authenticate? => @user, :authenticate! => @user)
    @bob = Factory.build(:user,:email => "bob@aol.com", :password => "secret")
    @status_message = Factory.build(:status_message, :message => "yodels.")
    @bob.save
    @status_message.save #TODO for some reason it complains about validations even though they are valid fields
  end

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
    response.should redirect_to(status_messages_url)
  end
  
  it "new action should render new template" do
    
    get :new
    response.should render_template(:new)
  end
  
  it "destroy action should destroy model and redirect to index action" do
    delete :destroy, :id => @status_message._id
    response.should redirect_to(status_messages_url)
    StatusMessage.first(:conditions => {:id => @status_message.id }).nil?.should be true
  end
  
  it "show action should render show template" do
    get :show, :id => @status_message.post_id
    response.should render_template(:show)
  end
  
  it "should return xml on show type if the MIME type exists" do
    request.env["HTTP_ACCEPT"] = "application/xml"
    message = StatusMessage.first
    get :show, :id => message.post_id
    response.body.include?(message.to_xml.to_s).should be true
  end

   it "should return xml on index if the MIME type exists" do
    Factory.create(:status_message)
     
    request.env["HTTP_ACCEPT"] = "application/xml"
    get :index
    StatusMessage.all.each do |message|
      response.body.include?(message.message).should be true
      response.body.include?(message.person.email).should be true
    end
  end
end
