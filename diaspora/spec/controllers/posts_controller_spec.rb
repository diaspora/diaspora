#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PostsController do
  before do
    sign_in alice
    aspect = alice.aspects.first
    @message = alice.build_post :status_message, :text => "ohai", :to => aspect.id
    @message.save!

    alice.add_to_streams(@message, [aspect])
    alice.dispatch_post @message, :to => aspect.id
  end

  describe '#show' do
    it 'succeeds' do
      get :show, "id" => @message.id.to_s
      response.should be_success
    end

    it 'succeeds on mobile' do
      get :show, "id" => @message.id.to_s, :format => :mobile
      response.should be_success
    end

    it 'succeeds on mobile with a reshare' do
      get :show, "id" => Factory(:reshare, :author => alice.person), :format => :mobile
      response.should be_success
    end

    it 'marks a corresponding notification as read' do
      alice.comment("comment after me", :post => @message)
      bob.comment("here you go", :post => @message)
      note = Notification.where(:recipient_id => alice.id, :target_id => @message.id).first
      lambda{
        get :show, :id => @message.id
        note.reload
      }.should change(note, :unread).from(true).to(false)
    end

    it 'redirects to back if there is no status message' do
      get :show, :id => 2345
      response.status.should == 302
    end

    it 'succeeds with a AS/photo' do
      photo = Factory(:activity_streams_photo, :author => bob.person)
      get :show, :id => photo.id
      response.should be_success
    end
  end
  describe '#destroy' do

    it 'let a user delete his message' do
      message = alice.post(:status_message, :text => "hey", :to => alice.aspects.first.id)
      delete :destroy, :format => :js, :id => message.id
      response.should be_success
      StatusMessage.find_by_id(message.id).should be_nil
    end

    it 'sends a retraction on delete' do
      controller.stub!(:current_user).and_return alice
      message = alice.post(:status_message, :text => "hey", :to => alice.aspects.first.id)
      alice.should_receive(:retract).with(message)
      delete :destroy, :format => :js, :id => message.id
      response.should be_success
    end

    it 'will not let you destroy posts visible to you' do
      message = bob.post(:status_message, :text => "hey", :to => bob.aspects.first.id)
      delete :destroy, :format => :js, :id => message.id
      response.should_not be_success
      StatusMessage.exists?(message.id).should be_true
    end

    it 'will not let you destory posts you do not own' do
      message = eve.post(:status_message, :text => "hey", :to => eve.aspects.first.id)
      delete :destroy, :format => :js, :id => message.id
      response.should_not be_success
      StatusMessage.exists?(message.id).should be_true
    end
  end
end
