#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StatusMessagesController do
  render_views

  let!(:user) { make_user }
  let!(:aspect) { user.aspect(:name => "lame-os") }

  before do
    sign_in :user, user
    @controller.stub!(:current_user).and_return(user)
  end

  describe '#create' do
    let(:status_message_hash) {{"status_message"=>{"public"=>"true", "message"=>"facebook, is that you?", "to" =>"#{aspect.id}"}}}

    context "posting out to facebook" do
      let!(:service2) { s = Factory(:service, :provider => 'facebook'); user.services << s; s }

      it 'should post to facebook when public is set' do
        user.should_receive(:post_to_facebook)
        post :create, status_message_hash
      end

      it 'should not post to facebook when public is not set' do
        status_message_hash['status_message']['public'] = 'false'
        user.should_not_receive(:post_to_facebook)
        post :create, status_message_hash
      end
    end

    context "posting to twitter" do
      let!(:service1) { s = Factory(:service, :provider => 'twitter'); user.services << s; s }

      it 'should post to twitter if public is set' do
        user.should_receive(:post_to_twitter).and_return(true)
        post :create, status_message_hash
      end

      it 'should not post to twitter when public in not set' do
        status_message_hash['status_message']['public'] = 'false'
        user.should_not_receive(:post_to_twitter)
        post :create, status_message_hash
      end
    end
  end
end
