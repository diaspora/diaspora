require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'capybara'
require 'capybara/wait_until'

module Capybara
  
  describe WaitUntil do
    
    it "should return result of yield if it returns true value within timeout" do
      WaitUntil.timeout { "hello" }.should == "hello"
    end
    
    it "should keep trying within timeout" do
      count = 0
      WaitUntil.timeout { count += 1; count == 5 ? count : nil }.should == 5
    end
    
    it "should raise Capybara::TimeoutError if block fails to return true within timeout" do
      running do 
        WaitUntil.timeout(0.1) { false }
      end.should raise_error(::Capybara::TimeoutError)
    end
    
  end
  
end
  