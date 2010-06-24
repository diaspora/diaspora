require File.dirname(__FILE__) + '/../spec_helper'

include ApplicationHelper 

describe ApplicationHelper do
  before do
    @user = Factory.create(:user, :email => "robert@grimm.com")
    @friend = Factory.create(:friend)
  end

  it "should specifiy if a post is not owned user" do
    p = Factory.create(:post, :person => @friend)
    mine?(p).should be false
  end

  it "should specifiy if a post is owned current user" do
    p = Factory.create(:post, :person => @user)
    mine?(p).should be true
  end

  it "should provide a correct show path for a given friend" do
    person_url(@friend).should == "/friends/#{@friend.id}"
  end

  it "should provide a correct show path for a given user" do
    person_url(@user).should == "/users/#{@user.id}"
  end
end
