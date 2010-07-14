require File.dirname(__FILE__) + '/../spec_helper'
 
describe DashboardsController do
 render_views
  
  before do
    request.env['warden'] = mock_model(Warden, :authenticate? => @user, :authenticate! => @user)
    @user = Factory.create(:user, :profile => Profile.new( :first_name => "bob", :last_name => "smith"))
  end

  it "on index sets a variable containing all a user's friends when a user is signed in" do
    sign_in :user, @user   
    Factory.create :person
    get :index
    assigns[:friends].should == Person.friends.all
  end

end
