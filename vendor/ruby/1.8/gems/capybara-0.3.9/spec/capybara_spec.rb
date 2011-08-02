require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'capybara'

describe Capybara do
  
  describe 'default_wait_time' do
    after do
      Capybara.default_wait_time = 2
    end
    
    it "should be changeable" do
      Capybara.default_wait_time = 5
      Capybara.default_wait_time.should == 5
    end
  end
  
end