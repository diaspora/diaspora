require 'spec_helper'

describe User do
  it "should be a person" do
    n = Person.count
    Factory.create(:user)
    Person.count.should == n+1
  end
end
