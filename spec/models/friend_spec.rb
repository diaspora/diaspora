require File.dirname(__FILE__) + '/../spec_helper'

describe Friend do
  it 'should have a diaspora username and diaspora url' do 
    n = Factory.build(:friend, :url => nil)
    n.valid?.should be false
    n.url = "http://max.com/"
    n.valid?.should be true
  end
end
