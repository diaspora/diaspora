#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StatusMessagesController do
  render_views

  before do
    @user1 = alice
    @user2 = bob

    @aspect1 = @user1.aspects.first
    @aspect2 = @user2.aspects.first

    request.env["HTTP_REFERER"] = ""
    sign_in :user, @user1
    @controller.stub!(:current_user).and_return(@user1)
    @user1.reload
  end

  describe '#show' do
    before do
      @message = @user1.build_post :status_message, :message => "ohai", :to => @aspect1.id
      @message.save!

      @user1.add_to_streams(@message, [@aspect1])
      @user1.dispatch_post @message, :to => @aspect1.id
    end

    it 'succeeds' do
      get :show, "id" => @message.id.to_s
      response.should be_success
    end

    it 'marks a corresponding notification as read' do
      alice.comment("comment after me", :on => @message)
      bob.comment("here you go", :on => @message)
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
  end

  describe '#create' do
    let(:status_message_hash) {
      { :status_message => {
        :public  => "true",
        :message => "facebook, is that you?",
        },
      :aspect_ids => [@aspect1.id.to_s] }
    }
    context 'js requests' do
      it 'responds' do
        post :create, status_message_hash.merge(:format => 'js')
        response.status.should == 201
      end
      it 'responds with json' do
        post :create, status_message_hash.merge(:format => 'js')
        json = JSON.parse(response.body)
        json['post_id'].should_not be_nil
        json['html'].should_not be_nil
      end
      it 'escapes XSS' do
        xss = "<script> alert('hi browser') </script>"
        post :create, status_message_hash.merge(:format => 'js', :message => xss)
        json = JSON.parse(response.body)
        json['html'].should_not =~ /<script>/
      end
    end

    it "dispatches the post to the specified services" do
      s1 = Services::Facebook.new
      @user1.services << s1
      @user1.services << Services::Twitter.new
      status_message_hash[:services] = ['facebook']
      @user1.should_receive(:dispatch_post).with(anything(), hash_including(:services => [s1]))
      post :create, status_message_hash
    end

    it "doesn't overwrite author_id" do
      status_message_hash[:status_message][:author_id] = @user2.person.id
      post :create, status_message_hash
      new_message = StatusMessage.find_by_message(status_message_hash[:status_message][:message])
      new_message.author_id.should == @user1.person.id
    end

    it "doesn't overwrite id" do
      old_status_message = @user1.post(:status_message, :message => "hello", :to => @aspect1.id)
      status_message_hash[:status_message][:id] = old_status_message.id
      post :create, status_message_hash
      old_status_message.reload.message.should == 'hello'
    end

    it 'calls dispatch post once subscribers is set' do
      @user1.should_receive(:dispatch_post){|post, opts|
        post.subscribers(@user1).should == [@user2.person]
      }
      post :create, status_message_hash
    end
    it 'sends the errors in the body on js' do
      post :create, status_message_hash.merge!(:format => 'js', :status_message => {:message => ''})
      response.body.should include('Status message requires a message or at least one photo')
    end


    context 'with photos' do
      before do
        fixture_filename  = 'button.png'
        fixture_name      = File.join(File.dirname(__FILE__), '..', 'fixtures', fixture_filename)

        @photo1 = @user1.build_post(:photo, :pending => true, :user_file=> File.open(fixture_name), :to => @aspect1.id)
        @photo2 = @user1.build_post(:photo, :pending => true, :user_file=> File.open(fixture_name), :to => @aspect1.id)

        @photo1.save!
        @photo2.save!

        @hash = status_message_hash
        @hash[:photos] = [@photo1.id.to_s, @photo2.id.to_s]
      end
      it "will post a photo without text" do
        @hash.delete :message
        post :create, @hash
        response.should be_redirect
      end
      it "dispatches all referenced photos" do
        @user1.should_receive(:dispatch_post).exactly(3).times
        post :create, @hash
      end
      it "sets the pending bit of referenced photos" do
        post :create, @hash
        @photo1.reload.pending.should be_false
        @photo2.reload.pending.should be_false
      end
    end
  end

  describe '#destroy' do
    let!(:message) {@user1.post(:status_message, :message => "hey", :to => @aspect1.id)}
    let!(:message2) {@user2.post(:status_message, :message => "hey", :to => @aspect2.id)}

    it 'let a user delete his photos' do
      delete :destroy, :id => message.id
      StatusMessage.find_by_id(message.id).should be_nil
    end

    it 'will not let you destroy posts visible to you' do
      delete :destroy, :id => message2.id
      StatusMessage.find_by_id(message2.id).should be_true
    end

    it 'will not let you destory posts you do not own' do
      delete :destroy, :id => message2.id
      StatusMessage.find_by_id(message2.id).should be_true
    end
  end
end
