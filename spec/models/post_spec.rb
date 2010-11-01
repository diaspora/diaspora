#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Post do
  before do
    @user = make_user
    @aspect = @user.aspects.create(:name => "winners")
  end

  describe 'deletion' do
    it 'should delete a posts comments on delete' do
      post = Factory.create(:status_message, :person => @user.person)
      @user.comment "hey", :on => post
      post.destroy
      Post.all(:id => post.id).empty?.should == true
      Comment.all(:text => "hey").empty?.should == true
    end
  end

  describe 'serialization' do
    it 'should serialize the handle and not the sender' do
      post = @user.post :status_message, :message => "hello", :to => @aspect.id
      xml = post.to_diaspora_xml

      xml.include?(@user.person.id.to_s).should be false
      xml.include?(@user.person.diaspora_handle).should be true
    end
  end
end

