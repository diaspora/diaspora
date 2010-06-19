require File.dirname(__FILE__) + '/../spec_helper'
 
describe DashboardController do
 render_views
  
  it "index action should render index template" do
    request.env['warden'] = mock_model(Warden, :authenticate? => @user, :authenticate! => @user)
    get :index
    response.should render_template(:index)
  end

end
