require File.dirname(__FILE__) + '/../spec_helper'
 
describe PublicsController do
 render_views
  
  before do
    @user = Factory.create(:user)
    sign_in :user, @user   
  end

  describe 'receive endpoint' do
    it 'should have a and endpoint and return a 200 on successful receipt of a request' do
      post :receive, :id =>@user.person.id
      response.code.should == '200'
    end
    
    it 'should accept a post from another node and save the information' do
      user2 = Factory.create(:user)
      message = user2.build_post(:status_message, :message => "hi")

      @user.reload
      @user.visible_post_ids.include?(message.id).should be false
      xml =  user2.salmon(message, :to => @user.person).to_xml

      post :receive, :id => @user.person.id, :xml => xml

      @user.reload
      @user.visible_post_ids.include?(message.id).should be true
    end
  end


  describe 'friend requests' do
    before do
      @user2 = Factory.create(:user)
      group = @user2.group(:name => 'disciples')

      @user3 = Factory.create(:user)

      req = @user2.send_friend_request_to(@user.person, group)

      @xml = req.to_diaspora_xml
  
      req.delete
      @user2.reload
      @user2.pending_requests.count.should be 1
    end

    it 'should add the pending request to the right user if the target person exists locally' do 
      @user2.delete
      post :receive, :id => @user.person.id, :xml => @xml
      
      assigns(:user).should eq(@user)
    end

    it 'should add the pending request to the right user if the target person does not exist locally' do 
      @user2.person.delete
      @user2.delete
      post :receive, :id => @user.person.id, :xml => @xml

      assigns(:user).should eq(@user)
    end
  end
end
