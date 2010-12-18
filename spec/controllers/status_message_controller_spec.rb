#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StatusMessagesController do
  render_views

  let!(:user1)   { make_user }
  let!(:aspect1) { user1.aspects.create(:name => "AWESOME!!") }

  let!(:user2)   { make_user }
  let!(:aspect2) { user2.aspects.create(:name => "WIN!!") }

  before do
    connect_users(user1, aspect1, user2, aspect2)
    request.env["HTTP_REFERER"] = ""
    sign_in :user, user1
    @controller.stub!(:current_user).and_return(user1)
  end

  describe '#show' do
    before do
      @video_id = "ABYnqp-bxvg"
      @url="http://www.youtube.com/watch?v=#{@video_id}&a=GxdCwVVULXdvEBKmx_f5ywvZ0zZHHHDU&list=ML&playnext=1"
    end
    it 'renders posts with youtube urls' do
      message = user1.build_post :status_message, :message => @url, :to => aspect1.id
      message[:youtube_titles]= {@video_id => "title"}
      message.save!
      user1.add_to_streams(message, aspect1.id)
      user1.dispatch_post message, :to => aspect1.id

      get :show, :id => message.id
      response.body.should match /Youtube: title/
    end
    it 'renders posts with comments with youtube urls' do
      message = user1.post :status_message, :message => "Respond to this with a video!", :to => aspect1.id
      @comment = user1.comment "none", :on => message
      @comment.text = @url
      @comment[:youtube_titles][@video_id] = "title"
      @comment.save!

      get :show, :id => message.id
      response.body.should match /Youtube: title/
    end
  end
  describe '#create' do
    let(:status_message_hash) {
      { :status_message => {
        :public  =>"true",
        :message =>"facebook, is that you?",
        :aspect_ids =>"#{aspect1.id}" }
      }
    }
    it 'responds to js requests' do
      post :create, status_message_hash.merge(:format => 'js')
      response.status.should == 201
    end

    it "doesn't overwrite person_id" do
      status_message_hash[:status_message][:person_id] = user2.person.id
      post :create, status_message_hash
      new_message = StatusMessage.find_by_message(status_message_hash[:status_message][:message])
      new_message.person_id.should == user1.person.id
    end

    it "doesn't overwrite id" do
      old_status_message = user1.post(:status_message, :message => "hello", :to => aspect1.id)
      status_message_hash[:status_message][:id] = old_status_message.id
      lambda {
        post :create, status_message_hash
      }.should raise_error /failed save/
      old_status_message.reload.message.should == 'hello'
    end

    it "dispatches all referenced photos" do
      fixture_filename  = 'button.png'
      fixture_name      = File.join(File.dirname(__FILE__), '..', 'fixtures', fixture_filename)

      photo1 = user1.build_post(:photo, :user_file=> File.open(fixture_name), :to => aspect1.id)
      photo2 = user1.build_post(:photo, :user_file=> File.open(fixture_name), :to => aspect1.id)

      photo1.save!
      photo2.save!

      hash = status_message_hash
      hash[:photos] = [photo1.id.to_s, photo2.id.to_s]

      user1.should_receive(:dispatch_post).exactly(3).times
      post :create, hash
    end
  end
  describe '#destroy' do
    let!(:message) {user1.post(:status_message, :message => "hey", :to => aspect1.id)}
    let!(:message2) {user2.post(:status_message, :message => "hey", :to => aspect2.id)}

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
