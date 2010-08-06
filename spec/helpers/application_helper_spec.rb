require File.dirname(__FILE__) + '/../spec_helper'

include ApplicationHelper 
describe ApplicationHelper do
  before do
    @user = Factory.create(:user)
    @person = Factory.create(:person)
    #env['warden'] = mock_model(Warden, :authenticate? => @user, :authenticate! => @user, :authenticate => @user)
    sign_in @user
    @user.save
  end

  it "should specifiy if a post is not owned user" do
    p = Factory.create(:post, :person => @person)
    mine?(p).should be false
  end

  it "should specifiy if a post is owned current user" do
    p = Factory.create(:post, :person => @user.person)
    
    puts p.person.id == @user.person.id
    
    mine?(p).should be true
  end

  it "should provide a correct show path for a given person" do
    person_url(@person).should == "/people/#{@person.id}"
  end

  it "should provide a correct show path for a given user" do
    person_url(@user).should == "/users/#{@user.id}"
  end
end
