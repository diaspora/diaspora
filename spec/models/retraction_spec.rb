#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Retraction do
    before do
      @user = Factory.create(:user)
      @person = Factory.create(:person)
      @aspect = @user.aspect(:name => "Bruisers")
      @user.activate_friend(@person, @aspect)
      @post = @user.post :status_message, :message => "Destroy!", :to => @aspect.id
    end
  describe 'serialization' do
    it 'should have a post id after serialization' do
      retraction = Retraction.for(@post)
      xml = retraction.to_xml.to_s
      xml.include?(@post.id.to_s).should == true
    end
  end
  describe 'dispatching' do
    it 'should dispatch a message on delete' do
      Factory.create(:person)
      User::QUEUE.should_receive :add_post_request
      @post.destroy
    end
  end
end
