require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  it "should require a real name" do
    u = Factory.build(:user, :real_name => nil)
    u.valid?.should be false
    u.real_name = "John Smith"
    u.valid?.should be true
  end
  it "should create a valid user with the factory" do
    u = Factory.build(:user)
    u.valid?.should be true
  end
  it "should be a person" do
    n = Person.count
    Factory.create(:user)
    Person.count.should == n+1
  end
  describe 'when posting' do
   before do
     @user = Factory.create :user
   end
    it "should be able to set a status message" do
      @user.post :status_message, :text => "I feel good"
      StatusMessage.where(:person_id => @user.id).last.message.should == "I feel good"
    end
    it "should return nil from an invalid post" do
      @user.post(:status_message, :text => "").should be_false
    end
  end
end
