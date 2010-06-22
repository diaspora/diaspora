require 'spec_helper'

describe User do
  it "should require a real name" do
    u = Factory.build(:user, :real_name => nil)
    u.valid?.should be false
    u.real_name = "John Smith"
    u.valid?.should be true
  end

end
