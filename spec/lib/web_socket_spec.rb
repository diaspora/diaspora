require File.dirname(__FILE__) + '/../spec_helper'



describe WebSocket do
  it 'should prepare a view along with an objects class in json' do
    
    EventMachine.run {
      include WebSocket
      user = Factory.create(:user)
      post = Factory.create(:status_message)
  
      json = WebSocket.view_hash(post)
      json.should include post.message
      
      EventMachine.stop
    }
  end
end