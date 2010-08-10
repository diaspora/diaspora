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
      post :receive, :id =>@user.id
      response.code.should == '200'
    end
    
    it 'should accept a post from another node and save the information' do

      person = Factory.create(:person)
      message = StatusMessage.new(:message => 'foo', :person => person)
      StatusMessage.all.count.should be 0
      post :receive, :id => @user.id, :xml => Post.build_xml_for(message)
      StatusMessage.all.count.should be 1
    end
  end



  it 'should save  requests for the specified user (LOCAL)' do 
    @user2 = Factory.create(:user)
    @user2.person.save

    req = Request.instantiate(:from => @user2.person, :to => @user.person.url)
    xml = Request.build_xml_for [req]
    
    puts xml
    

    req.delete
    post :receive, :id =>@user.id, :xml => xml
    
    @user2.pending_requests.count.should be 1
    @user.pending_requests.count.should be 1
  end

end
