require File.dirname(__FILE__) + '/../spec_helper'

 
describe PublicsController do
 render_views
  
  before do
    @user = Factory.create(:user)
    @user.person.save
    request.env['warden'] = mock_model(Warden, :authenticate? => @user, :authenticate! => @user, :authenticate => @user)
  end

  describe 'receive endpoint' do
    it 'should have a and endpoint and return a 200 on successful receipt of a request' do
      post :receive, :id =>@user.person.id
      response.code.should == '200'
    end
    
    it 'should accept a post from another node and save the information' do
      pending
      person = Factory.create(:person)
      message = StatusMessage.new(:message => 'foo', :person => person)
      StatusMessage.all.count.should be 0
      post :receive, :id => @user.person.id, :xml => Post.build_xml_for(message)
      StatusMessage.all.count.should be 1
    end
  end


  describe 'friend requests' do
    before do
      @user2 = Factory.create(:user)
      @user2.person.save

      req = Request.instantiate(:from => @user2.person, :to => @user.person.url)
      @xml = Request.build_xml_for [req]
  
      req.delete
    end

    it 'should save requests for the specified user (LOCAL)' do 
      post :receive, :id => @user.person.id, :xml => @xml
      
      @user.reload
      @user.pending_requests.size.should be 1
    end

    it 'should save  requests for the specified user (REMOTE)' do 
      @user2.person.delete
      @user2.delete
      post :receive, :id => @user.person.id, :xml => @xml
      
      @user.reload
      @user.pending_requests.size.should be 1
    end


  end
end
