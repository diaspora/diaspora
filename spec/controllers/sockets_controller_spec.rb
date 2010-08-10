require File.dirname(__FILE__) + '/../spec_helper'

describe 'SocketsController' do
  render_views  
  before do
    @user = Factory.create(:user)
    SocketsController.unstub!(:new)
    #EventMachine::WebSocket.stub!(:start)
    @controller = SocketsController.new
    @controller.request = mock_model(Request, :env =>
      {'warden' => mock_model(Warden, :authenticate? => @user, :authenticate! => @user, :authenticate => @user)})
    stub_sockets_controller
  end

  it 'should unstub the websockets' do
      WebSocket.initialize_channels
      @controller.class.should == SocketsController
  end
  
  describe 'actionhash' do
    before do
      @message = @user.post :status_message, :message => "post through user for victory"
    end

    it 'should actionhash posts' do
      json = @controller.action_hash(@user.id, @message)
      json.include?(@message.message).should be_true
      json.include?('status_message').should be_true
    end

    it 'should actionhash retractions' do
      retraction = Retraction.for @message
      json = @controller.action_hash(@user.id, retraction)
      json.include?('retraction').should be_true
      json.include?("html\":null").should be_true
    end
  end
end
