require File.dirname(__FILE__) + '/../spec_helper'

describe SocketController do
  before do
    Factory.create(:user)
    WebSocket.unstub!(:push_to_clients)
    WebSocket.unstub!(:unsubscribe)
    WebSocket.unstub!(:subscribe)
    #EventMachine::WebSocket.stub!(:start)
    @controller = SocketController.new
  end

  it 'should unstub the websocket' do
    EventMachine.run {
      puts"hi"
      WebSocket.initialize_channel
      WebSocket.push_to_clients("what").should_not == "stub"
      WebSocket.unsubscribe(1).should_not == "stub"
      WebSocket.subscribe.should_not == "stub"
      EventMachine.stop
    }
    puts "yo"
  end
  
  it 'should add a new subscriber to the websocket channel' do
    EventMachine.run {
      puts "foo"
      WebSocket.initialize_channel
      @controller.new_subscriber.should == 1

      EventMachine.stop
    }
  end


end
