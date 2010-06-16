require File.dirname(__FILE__) + '/../spec_helper'
 
describe DashboardController do
  fixtures :all
  integrate_views
  
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
end
