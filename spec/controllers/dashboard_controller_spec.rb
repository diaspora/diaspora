require File.dirname(__FILE__) + '/../spec_helper'
 
describe DashboardController do
 render_views
  
  before do
    request.env['warden'] = mock_model(Warden, :authenticate? => @user, :authenticate! => @user)
    Factory.create(:user, :profile => Profile.create( :first_name => "bob", :last_name => "smith"))
  end
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
  it "on index sets a friends variable" do
    Factory.create :friend
    get :index
    assigns[:friends].should == Friend.all
  end

end
