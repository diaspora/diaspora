require File.dirname(__FILE__) + '/../spec_helper'

#require 'em-spec/rspec'
describe SocketController do
  render_views
  
  before do
    @user = Factory.create(:user)
    WebSocket.unstub!(:push_to_clients)
    WebSocket.unstub!(:unsubscribe)
    WebSocket.unstub!(:subscribe)
    #EventMachine::WebSocket.stub!(:start)
    @controller = SocketController.new
  end

  it 'should unstub the websocket' do
      WebSocket.initialize_channel
      WebSocket.push_to_clients("what").should_not == "stub"
      WebSocket.unsubscribe(1).should_not == "stub"
      WebSocket.subscribe.should_not == "stub"
  end
  
  it 'should add a new subscriber to the websocket channel' do
      WebSocket.initialize_channel
      @controller.new_subscriber.should == 1
  end
  describe 'actionhash' do
    before do
      @message = Factory.create(:status_message, :person => @user)
    end

    it 'should actionhash posts' do
      hash = @controller.action_hash(@message)
      hash[:html].include?(@message.message).should be_true
      hash[:class].include?('status_message').should be_true
    end

    it 'should actionhash retractions' do
      retraction = Retraction.for @message
      hash = @controller.action_hash(retraction)
      hash[:class].include?('retraction').should be_true
      hash[:html].should be_nil
    end
  end
end
