require File.dirname(__FILE__) + '/../spec_helper'

describe 'SocketController' do
  render_views  
  before do
    @user = Factory.create(:user)
    SocketController.unstub!(:new)
    #EventMachine::WebSocket.stub!(:start)
    @controller = SocketController.new
    stub_socket_controller
  end

  it 'should unstub the websocket' do
      WebSocket.initialize_channel
      @controller.class.should == SocketController
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
      json = @controller.action_hash(@message)
      json.include?(@message.message).should be_true
      json.include?('status_message').should be_true
    end

    it 'should actionhash retractions' do
      retraction = Retraction.for @message
      json = @controller.action_hash(retraction)
      json.include?('retraction').should be_true
      json.include?("html\":null").should be_true
    end
  end
end
