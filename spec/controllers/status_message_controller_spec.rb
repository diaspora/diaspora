#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StatusMessagesController do
  render_views

  let!(:user) { make_user }
  let!(:aspect) { user.aspects.create(:name => "AWESOME!!") }

  let!(:user2) { make_user }
  let!(:aspect2) { user2.aspects.create(:name => "WIN!!") }

  before do
    friend_users(user, aspect, user2, aspect2)
    sign_in :user, user
    @controller.stub!(:current_user).and_return(user)
  end

  describe '#create' do
    let(:status_message_hash) {
      {:status_message =>{
        :public  =>"true", 
        :message =>"facebook, is that you?", 
        :to      =>"#{aspect.id}"}}
    }

    context "posting out to facebook" do
      let!(:service2) { s = Factory(:service, :provider => 'facebook'); user.services << s; s }

      it 'should post to facebook when public is set' do
        user.should_receive(:post_to_facebook)
        post :create, status_message_hash
      end

      it 'should not post to facebook when public is not set' do
        status_message_hash[:status_message][:public] = 'false'
        user.should_not_receive(:post_to_facebook)
        post :create, status_message_hash
      end
      it "doesn't overwrite person_id" do
        new_user = make_user
        status_message_hash[:status_message][:person_id] = new_user.person.id
        post :create, status_message_hash
        StatusMessage.find_by_message(status_message_hash[:status_message][:message]).person_id.should == user.person.id
      end
      it "doesn't overwrite id" do
        old_status_message = user.post(:status_message, :message => "hello", :to => aspect.id)
        status_message_hash[:status_message][:id] = old_status_message.id
        lambda {post :create, status_message_hash}.should raise_error /failed save/
        old_status_message.reload.message.should == 'hello'
      end
    end

    context "posting to twitter" do
      let!(:service1) { s = Factory(:service, :provider => 'twitter'); user.services << s; s }

      it 'should post to twitter if public is set' do
        user.should_receive(:post_to_twitter).and_return(true)
        post :create, status_message_hash
      end

      it 'should not post to twitter when public in not set' do
        status_message_hash[:status_message][:public] = 'false'
        user.should_not_receive(:post_to_twitter)
        post :create, status_message_hash
      end
    end
  end

  describe '#destroy' do
    let!(:message) {user.post(:status_message, :message => "hey", :to => aspect.id)}
    let!(:message2) {user2.post(:status_message, :message => "hey", :to => aspect2.id)}

    it 'should let me delete my photos' do
      delete :destroy, :id => message.id
      StatusMessage.find_by_id(message.id).should be_nil
    end

    it 'will not let you destroy posts visible to you' do
      user.receive message2.to_diaspora_xml, user2.person
      user.visible_posts.include?(message2).should be true
      delete :destroy, :id => message2.id
      StatusMessage.find_by_id(message2.id).should_not be_nil
    end

    it 'will not let you destory posts you do not own' do
      user.visible_posts.include?(message2).should be false
      delete :destroy, :id => message2.id
      StatusMessage.find_by_id(message2.id).should_not be_nil
    end

  end
end
