require File.dirname(__FILE__) + '/../spec_helper'

describe StatusMessage do
  it "should have a message" do    
    n = StatusMessage.new
    n.valid?.should be false
    n.message = "wales"
    n.valid?.should be true
  end
end
