require 'spec_helper'

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

end
