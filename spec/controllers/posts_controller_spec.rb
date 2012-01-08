#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PostsController do
  before do
    aspect = alice.aspects.first
    @message = alice.build_post :status_message, :text => "ohai", :to => aspect.id
    @message.save!

    alice.add_to_streams(@message, [aspect])
    alice.dispatch_post @message, :to => aspect.id
  end

  describe '#show' do
    context 'user signed in' do
      before do
        sign_in alice
      end

      it 'succeeds' do
        get :show, "id" => @message.id
        response.should be_success
      end

      it 'succeeds on mobile' do
        get :show, "id" => @message.id
        response.should be_success
      end

      it 'succeeds on mobile with a reshare' do
        get :show, "id" => Factory(:reshare, :author => alice.person).id, :format => :mobile
        response.should be_success
      end

      it 'marks a corresponding notification as read' do
        note = Notification.create(:recipient => alice, :target => @message, :unread => true)

        lambda{
          get :show, :id => @message.id
          note.reload
        }.should change(note, :unread).from(true).to(false)
      end

      it 'succeeds with a AS/photo' do
        photo = Factory(:activity_streams_photo, :author => bob.person)
        get :show, :id => photo.id
        response.should be_success
      end
    end

    context 'user not signed in' do
      context 'given a public post' do
        before :each do
          @status = alice.post(:status_message, :text => "hello", :public => true, :to => 'all')
        end

        it 'shows a public post' do
          get :show, :id => @status.id
          response.status.should == 200
        end

        it 'succeeds for statusnet' do
          @request.env["HTTP_ACCEPT"] = "application/html+xml,text/html"
          get :show, :id => @status.id
          response.should be_success
        end

        it 'responds with diaspora xml if format is xml' do
          get :show, :id => @status.guid, :format => :xml
          response.body.should == @status.to_diaspora_xml
        end
      end

      it 'does not show a private post' do
        status = alice.post(:status_message, :text => "hello", :public => false, :to => 'all')
        get :show, :id => status.id
        response.status = 302
      end

      # We want to be using guids from now on for this post route, but do not want to break
      # pre-exisiting permalinks.  We can assume a guid is 8 characters long as we have
      # guids set to hex(8) since we started using them.
      context 'id/guid switch' do
        before do
          @status = alice.post(:status_message, :text => "hello", :public => true, :to => 'all')
        end

        it 'assumes guids less than 8 chars are ids and not guids' do
          Post.should_receive(:where).with(hash_including(:id => @status.id)).and_return(Post)
          get :show, :id => @status.id
          response.should be_success
        end

        it 'assumes guids more than (or equal to) 8 chars are actually guids' do
          Post.should_receive(:where).with(hash_including(:guid => @status.guid)).and_return(Post)
          get :show, :id => @status.guid
          response.should be_success
        end
      end
    end
  end

  describe '#destroy' do
    before do
      sign_in alice
    end

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

  describe '#index' do
    before do
      sign_in alice
    end

    it 'will succeed if admin' do
      AppConfig[:admins] = [alice.username]
      get :index
      response.should be_success
    end

    it 'will redirect if not' do
      AppConfig[:admins] = []
      get :index
      response.should be_redirect
    end

  end
end
