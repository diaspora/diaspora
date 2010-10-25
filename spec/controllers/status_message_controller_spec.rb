#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StatusMessagesController do
  render_views

  let!(:user) { Factory(:user) }
  let!(:aspect) { user.aspect(:name => "lame-os") }

  before do
    sign_in :user, user
    @controller.stub!(:current_user).and_return(user)
  end

  describe '#create' do
    let(:status_message_hash) {{"status_message"=>{"public"=>"1", "message"=>"facebook, is that you?", "to" =>"#{aspect.id}"}}}


    context "posting out to facebook" do
      before do
        @controller.stub!(:logged_into_fb?).and_return(true)
      end

      it 'should post to facebook when public is set' do
        user.should_receive(:post_to_facebook)
        post :create, status_message_hash
      end

      it 'should not post to facebook when public in not set' do
        status_message_hash['status_message']['public'] = '0'
        user.should_not_receive(:post_to_facebook)
        post :create, status_message_hash
      end
    end


    context "posting to twitter" do
      it 'should post to twitter if public is set' do
        user.should_receive(:post_to_twitter).and_return(true)
        post :create, status_message_hash
      end

      it 'should not post to twitter when public in not set' do
        status_message_hash['status_message']['public'] = '0'
        user.should_not_receive(:post_to_twitter)
        post :create, status_message_hash
      end
    end
  end
end
