require File.dirname(__FILE__) + '/../spec_helper'
EventMachine.run{
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
    EventMachine.next_tick {
      WebSocket.initialize_channel
      WebSocket.push_to_clients("what").should_not == "stub"
      WebSocket.unsubscribe(1).should_not == "stub"
      WebSocket.subscribe.should_not == "stub"
    }
  end
  
  it 'should add a new subscriber to the websocket channel' do
    EventMachine.next_tick {
      WebSocket.initialize_channel
      @controller.new_subscriber.should == 1
    }
  end


end
EventMachine.stop
}
