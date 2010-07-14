require File.dirname(__FILE__) + '/../spec_helper'
 
describe DashboardsController do
 render_views
  
  before do
    @user = Factory.create(:user, :profile => Profile.new( :first_name => "bob", :last_name => "smith"))
    request.env['warden'] = mock_model(Warden, :authenticate? => @user, :authenticate! => @user, :authenticate => @user)
  end

  it "on index sets a variable containing all a user's friends when a user is signed in" do
    sign_in :user, @user   
    Factory.create :person
    get :index
    assigns[:friends].should == Person.friends.all
  end

  describe 'PubSubHubBuB intergration' do 

    describe 'incoming subscriptions' do
      it 'should register a friend' do
        Subscriber.all.count.should == 0 
       
        post :hub,  {:callback => "http://example.com/", 
                            :mode => 'subscribe', 
                            :topic => '/status_messages',
                            :verify => 'async'}
        response.status.should == 202
        
        Subscriber.all.count.should == 1
      end

      it 'should keep track of what topic a subscriber wants' do 
        post :hub,  {:callback => "http://example.com/", 
                            :mode => 'subscribe', 
                            :topic => '/status_messages',
                            :verify => 'async'}
        Subscriber.first.topic.should == '/status_messages' 
      end
    end
    
    it 'should return a 204 for a sync request' do
        post :hub,  {:callback => "http://example.com/", 
                            :mode => 'subscribe', 
                            :topic => '/status_messages',
                            :verify => 'sync'}
        response.status.should == 204
    end
    
    it 'should confirm subscription of a sync request' do
      post :hub,  {:callback => "http://example.com/", 
                   :mode => 'subscribe', 
                   :topic => '/status_messages',
                   :verify => 'sync'}
     
    end

  end
end
