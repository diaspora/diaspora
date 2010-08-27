require File.dirname(__FILE__) + '/../spec_helper'
include ApplicationHelper 
describe GroupsController do
 render_views
  before do
    @user = Factory.create(:user)
    @user.group(:name => "lame-os")
    @person = Factory.create(:person)
    sign_in :user, @user   
  end

  it "on index sets a variable containing all a user's friends when a user is signed in" do
    sign_in :user, @user   
    Factory.create :person
    get :index
    assigns[:friends].should == @user.friends
  end

end
