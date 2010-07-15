require File.dirname(__FILE__) + '/../spec_helper'
 
describe PublicsController do
 render_views
  
  before do
    @user = Factory.create(:user, :profile => Profile.new( :first_name => "bob", :last_name => "smith"))
    request.env['warden'] = mock_model(Warden, :authenticate? => @user, :authenticate! => @user, :authenticate => @user)
  end

  describe 'PubSubHubBuB intergration' do 

    describe 'incoming subscriptions' do
      it 'should respond to a incoming subscription request' do
       
        get :hubbub,  {'hub.callback' => "http://example.com/", 
                        'hub.mode' => 'subscribe', 
                        'hub.topic' => '/status_messages',
                        'hub.verify' => 'sync',
                        'hub.challenge' => 'foobar'}
        response.status.should == 202
        response.body.should == 'foobar'
      end
    end
  end
end
