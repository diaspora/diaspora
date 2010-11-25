#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StatusMessagesController do
  render_views

  let!(:user)    { make_user }
  let!(:aspect)  { user.aspects.create(:name => "AWESOME!!") }

  let!(:user2)   { make_user }
  let!(:aspect2) { user2.aspects.create(:name => "WIN!!") }

  before do
    connect_users(user, aspect, user2, aspect2)
    request.env["HTTP_REFERER"] = ""
    sign_in :user, user
    @controller.stub!(:current_user) { user }
  end

  describe '#create' do
    let(:status_message_hash) {
      {
        :status_message => {
          :public  => "true",
          :message => "facebook, is that you?",
          :to      => "#{aspect.id}"
        }
      }
    }

    it "doesn't overwrite person_id" do
      new_user = make_user
      status_message_hash[:status_message][:person_id] = new_user.person.id
      post :create, status_message_hash
      StatusMessage.find_by_message(status_message_hash[:status_message][:message]).person_id.should ==
        user.person.id
    end

    it "doesn't overwrite id" do
      old_status_message = user.post(:status_message, :message => "hello", :to => aspect.id)
      status_message_hash[:status_message][:id] = old_status_message.id
      expect { post :create, status_message_hash }.to raise_error /failed save/
      old_status_message.reload.message.should == 'hello'
    end

    it "dispatches all referenced photos" do
      fixture_filename  = 'button.png'
      fixture_name      = File.join(File.dirname(__FILE__), '..', 'fixtures', fixture_filename)

      photo1 = user.build_post(:photo, :user_file=> File.open(fixture_name), :to => aspect.id)
      photo2 = user.build_post(:photo, :user_file=> File.open(fixture_name), :to => aspect.id)

      photo1.save!
      photo2.save!

      hash = status_message_hash
      hash[:photos] = [photo1.id.to_s, photo2.id.to_s]

      user.should_receive(:dispatch_post).exactly(3).times
      post :create, hash
    end

    context "posting out to facebook" do
      let!(:service2) { s = Factory(:service, :provider => 'facebook'); user.services << s; s }

      it 'posts to facebook when public is set' do
        user.should_receive(:post_to_facebook)
        post :create, status_message_hash
      end

      it 'does not post to facebook when public is not set' do
        status_message_hash[:status_message][:public] = 'false'
        user.should_not_receive(:post_to_facebook)
        post :create, status_message_hash
      end
    end

    context "posting to twitter" do
      let!(:service1) { s = Factory(:service, :provider => 'twitter'); user.services << s; s }

      it 'posts to twitter if public is set' do
        user.should_receive(:post_to_twitter).and_return(true)
        post :create, status_message_hash
      end

      it 'does not post to twitter when public in not set' do
        status_message_hash[:status_message][:public] = 'false'
        user.should_not_receive(:post_to_twitter)
        post :create, status_message_hash
      end
    end
  end

  describe '#destroy' do
    let!(:message)  { user.post(:status_message, :message => "hey", :to => aspect.id)   }
    let!(:message2) { user2.post(:status_message, :message => "hey", :to => aspect2.id) }

    it 'lets me delete my photos' do
      delete :destroy, :id => message.id
      StatusMessage.find_by_id(message.id).should be_nil
    end

    it "won't let you destroy posts visible to you" do
      delete :destroy, :id => message2.id
      StatusMessage.find_by_id(message2.id).should_not be_nil
    end

    it "won't let you destroy posts you don't own" do
      delete :destroy, :id => message2.id
      StatusMessage.find_by_id(message2.id).should_not be_nil
    end
  end
end
