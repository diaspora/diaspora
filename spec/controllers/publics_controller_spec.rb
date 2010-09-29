#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

require 'spec_helper'

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
      xml =  @user.person.encrypt(user2.salmon(message, :to => @user.person).to_xml)

      post :receive, :id => @user.person.id, :xml => xml

      @user.reload
      @user.visible_post_ids.include?(message.id).should be true
    end
  end

  describe 'webfinger' do
    it 'should not try to webfinger out on a request to webfinger' do
      Redfinger.should_not_receive :finger
      post :webfinger, :q => 'remote@example.com'
    end
  end

  describe 'friend requests' do
    before do
      @user2 = Factory.create(:user)
      aspect = @user2.aspect(:name => 'disciples')

      @user3 = Factory.create(:user)

      req = @user2.send_friend_request_to(@user.person, aspect)

      @xml = @user.person.encrypt(@user2.salmon(req, :to => @user.person).to_xml)

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
      Person.should_receive(:by_webfinger).with(@user2.person.diaspora_handle).and_return(@user2.person)
      @user2.person.delete
      @user2.delete
      post :receive, :id => @user.person.id, :xml => @xml

      assigns(:user).should eq(@user)
    end
  end
end
