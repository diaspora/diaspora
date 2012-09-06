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

      it 'renders the application layout on mobile' do
        get :show, :id => @message.id, :format => :mobile
        response.should render_template('layouts/application')
      end

      it 'succeeds on mobile with a reshare' do
        get :show, "id" => FactoryGirl.create(:reshare, :author => alice.person).id, :format => :mobile
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
        photo = FactoryGirl.create(:activity_streams_photo, :author => bob.person)
        get :show, :id => photo.id
        response.should be_success
      end

      it '404 if the post is missing' do
        expect {
          get :show, :id => 1234567
        }.to raise_error(ActiveRecord::RecordNotFound)
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
        response.status.should == 404
      end

      # We want to be using guids from now on for this post route, but do not want to break
      # pre-exisiting permalinks.  We can assume a guid is 8 characters long as we have
      # guids set to hex(8) since we started using them.
      context 'id/guid switch' do
        before do
          @status = alice.post(:status_message, :text => "hello", :public => true, :to => 'all')
        end

        it 'assumes guids less than 8 chars are ids and not guids' do
          p = Post.where(:id => @status.id.to_s)
          Post.should_receive(:where)
              .with(hash_including(:id => @status.id.to_s))
              .and_return(p)
          get :show, :id => @status.id
          response.should be_success
        end

        it 'assumes guids more than (or equal to) 8 chars are actually guids' do
          p = Post.where(:guid => @status.guid)
          Post.should_receive(:where)
              .with(hash_including(:guid => @status.guid))
              .and_return(p)
          get :show, :id => @status.guid
          response.should be_success
        end
      end
    end
  end

  describe 'iframe' do
    it 'contains an iframe' do
      get :iframe, :id => @message.id
      response.body.should match /iframe/
    end
  end

  describe 'oembed' do
    it 'works when you can see it' do
      sign_in alice
      get :oembed, :url => "/posts/#{@message.id}"
      response.body.should match /iframe/
    end

    it 'returns a 404 response when the post is not found' do
      get :oembed, :url => "/posts/#{@message.id}"
      response.status.should == 404
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
      expect { delete :destroy, :format => :js, :id => message.id }.to raise_error(ActiveRecord::RecordNotFound)
      StatusMessage.exists?(message.id).should be_true
    end

    it 'will not let you destory posts you do not own' do
      message = eve.post(:status_message, :text => "hey", :to => eve.aspects.first.id)
      expect { delete :destroy, :format => :js, :id => message.id }.to raise_error(ActiveRecord::RecordNotFound)
      StatusMessage.exists?(message.id).should be_true
    end
  end

  describe "#next" do
    before do
      sign_in alice
      Post.stub(:find_by_guid_or_id_with_user).and_return(mock_model(Post, :author => 4))
      Post.stub_chain(:visible_from_author, :newer).and_return(next_post)
    end

    let(:next_post){ mock_model(StatusMessage, :id => 34)}

    context "GET .json" do
      let(:mock_presenter) { mock(:as_json => {:title => "the unbearable lightness of being"}) }

      it "should return a show presenter the next post" do
        PostPresenter.should_receive(:new).with(next_post, alice).and_return(mock_presenter)
        get :next, :id => 14, :format => :json
        response.body.should == {:title => "the unbearable lightness of being"}.to_json
      end
    end

    context "GET .html" do
      it "should redirect to the next post" do
        get :next, :id => 14
        response.should redirect_to(post_path(next_post))
      end
    end
  end

  describe "previous" do
    before do
      sign_in alice
      Post.stub(:find_by_guid_or_id_with_user).and_return(mock_model(Post, :author => 4))
      Post.stub_chain(:visible_from_author, :older).and_return(previous_post)
    end

    let(:previous_post){ mock_model(StatusMessage, :id => 11)}

    context "GET .json" do
      let(:mock_presenter) { mock(:as_json => {:title => "existential crises"})}

      it "should return a show presenter the next post" do
        PostPresenter.should_receive(:new).with(previous_post, alice).and_return(mock_presenter)
        get :previous, :id => 14, :format => :json
        response.body.should == {:title => "existential crises"}.to_json
      end
    end

    context "GET .html" do
      it "should redirect to the next post" do
        get :previous, :id => 14
        response.should redirect_to(post_path(previous_post))
      end
    end
  end
end
