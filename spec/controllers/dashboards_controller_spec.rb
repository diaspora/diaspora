require File.dirname(__FILE__) + '/../spec_helper'
include ApplicationHelper 
describe DashboardsController do
 render_views
  before do
    @user = Factory.create(:user)
    @user.person.save
    @person = Factory.create(:person)
    request.env['warden'] = mock_model(Warden, :authenticate? => @user, :authenticate! => @user, :authenticate => @user)
  end

  it "on index sets a variable containing all a user's friends when a user is signed in" do
    sign_in :user, @user   
    Factory.create :person
    get :index
    assigns[:friends].should == @user.friends
  end

end
