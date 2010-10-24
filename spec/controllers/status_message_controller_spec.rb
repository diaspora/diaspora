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
  end

  describe '#create' do
   let(:status_message_hash) {{"status_message"=>{"public"=>"1", "message"=>"facebook, is that you?", "to" =>"#{aspect.id}"}}}
    
   before do
     @controller.stub!(:logged_into_fb?).and_return(true)
   end

   it 'should post to facebook when public is set' do
     my_mock = mock("http")
     my_mock.stub!(:post)
     EventMachine::HttpRequest.should_receive(:new).and_return(my_mock)
     post :create, status_message_hash
   end
   
   it 'should not post to facebook when public in not set' do
     status_message_hash['status_message']['public'] = '0'
     EventMachine::HttpRequest.should_not_receive(:new)
     post :create, status_message_hash
   end
  end
end

