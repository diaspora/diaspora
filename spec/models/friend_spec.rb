require File.dirname(__FILE__) + '/../spec_helper'

describe Friend do
  it 'should have a diaspora username + diaspora url' do
    n = Friend.new(:username => 'max')
    n.valid?.should == false
    n.url = "http://max.com/"
    n.valid?.should == true
  end
  
  
end