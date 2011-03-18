require 'spec_helper'

describe Job::UpdateServiceUsers do
  before do
    @user = alice
    @post = @user.post(:status_message, :text => "hello", :to =>@user.aspects.first.id)
    @service = Services::Facebook.new(:access_token => "yeah")
    @user.services << @service

    @user2 = Factory.create(:user_with_aspect)
    @user2_fb_id = '820651'
    @user2_fb_name = 'Maxwell Salzberg'
    @user2_service = Services::Facebook.new(:uid => @user2_fb_id, :access_token => "yo")
    @user2.services << @user2_service
    @fb_list_hash =  <<JSON
    {
      "data": [
        {
          "name": "#{@user2_fb_name}",
          "id": "#{@user2_fb_id}"
        },
        {
          "name": "Person to Invite",
          "id": "abc123"
        }
      ]
    }
JSON
    @web_mock = mock()
    @web_mock.stub!(:body).and_return(@fb_list_hash)
    RestClient.stub!(:get).and_return(@web_mock)
  end

  it 'requests a friend list' do
    RestClient.should_receive(:get).with("https://graph.facebook.com/me/friends", {:params => {:access_token => @service.access_token}}).and_return(@web_mock)
    Job::UpdateServiceUsers.perform(@service.id)
  end
  
  it 'creates a service user objects' do
    lambda{
      Job::UpdateServiceUsers.perform(@service.id)
    }.should change(ServiceUser, :count).by(2)
  end
 end
