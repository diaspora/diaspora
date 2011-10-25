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
        doc.should have_link('Like')
        doc.should have_link('Comment')
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
        alice.comment("comment after me", :post => @message)
        bob.comment("here you go", :post => @message)
        note = Notification.where(:recipient_id => alice.id, :target_id => @message.id).first
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

        context 'with more than 3 comments' do
          before do
            (1..5).each do |i|
              alice.comment  "comment #{i}", :post => @status
            end
          end

          it 'shows all comments of a public post' do
            get :show, :id => @status.id

            response.body.should =~ /comment 3/
            response.body.should_not =~ /comment 2/

            get :show, :id => @status.id, 'all_comments' => '1'

            response.body.should =~ /comment 3/
            response.body.should =~ /comment 2/
          end
        end

      end

      it 'shows a public photo' do
        pending
        status = Factory(:status_message_with_photo, :public => true, :author => alice.person)
        photo = status.photos.first
        get :show, :id => photo.id
        response.status.should == 200
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
          response.status= 200
        end

        it 'assumes guids more than (or equal to) 8 chars are actually guids' do
          Post.should_receive(:where).with(hash_including(:guid => @status.guid)).and_return(Post)
          get :show, :id => @status.guid
          response.status= 200
        end
      end
    end

    context 'when a post is public' do
      before do
        @post = alice.post( :status_message, :public => true, :to => alice.aspects, :text => 'abc 123' )
      end

      context 'and visitor is not signed in' do
        it 'does not show social links' do
          get :show, 'id' => @post.id

          doc.should have_content('abc 123')
          doc.should_not have_link('Like')
          doc.should_not have_link('Comment')
          doc.should_not have_link('Reshare')
        end
      end

      context 'and signed in as poster' do
        before do
          sign_in alice
        end

        it 'does not show a reshare link' do
          get :show, 'id' => @post.id

          doc.should have_content('abc 123')
          doc.should have_link('Like')
          doc.should have_link('Comment')
          doc.should_not have_link('Reshare')
        end

        context 'a reshare of the post' do
          before do
            @reshare = bob.post( :reshare, :public => true, :root_guid => @post.guid, :to => bob.aspects )
          end

          it 'does not show a reshare link' do
            get :show, 'id' => @reshare.id

            doc.should have_content('abc 123')
            doc.should have_link('Like')
            doc.should have_link('Comment')
            doc.should_not have_link('Reshare')
            doc.should_not have_link('Reshare original')
            doc.should_not have_link('1 reshare')
          end
        end
      end

      context 'and signed in as someone other than the poster' do
        before do
          sign_in bob
        end

        it 'shows reshare link' do
          get :show, 'id' => @post.id

          doc.should have_content('abc 123')
          doc.should have_link('Like')
          doc.should have_link('Comment')
          doc.should have_link('Reshare')
        end
      end

      context 'and signed in as the resharer of the post' do
        context 'a reshare of the post' do
          before do
            @reshare = bob.post( :reshare, :public => true, :root_guid => @post.guid, :to => bob.aspects )
            # Don't know why this is needed, but this spec fails without it
            sign_in bob
          end

          it 'does not show any reshare link' do
            get :show, 'id' => @reshare.id

            doc.should have_content('abc 123')
            doc.should have_link('Like')
            doc.should have_link('Comment')
            doc.should_not have_link('1 reshare')
            doc.should_not have_link('Reshare')
          end
        end
      end

      context 'and signed in as neither the poster nor the resharer of the post' do
        before do
          sign_in eve
        end

        it 'shows reshare link' do
          get :show, 'id' => @post.id

          doc.should have_content('abc 123')
          doc.should have_link('Like')
          doc.should have_link('Comment')
          doc.should have_link('Reshare')
        end

        context 'a reshare of the post' do
          before do
            @reshare = bob.post( :reshare, :public => true, :root_guid => @post.guid, :to => bob.aspects )
          end

          it 'shows a reshare link' do
            get :show, 'id' => @reshare.id

            doc.should have_content('abc 123')
            doc.should have_link('Like')
            doc.should have_link('Comment')
            doc.should have_link('Reshare original')
          end
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
