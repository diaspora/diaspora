require File.dirname(__FILE__) + '/../spec_helper'

describe Subscriber do
  it 'should require a url' do
    n = Subscriber.new
    n.valid?.should be false
    
    n.topic = '/status_messages'
    n.valid?.should be false

    n.url = "http://clown.com/"

    n.valid?.should be true
  end
end
