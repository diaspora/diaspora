#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Post do
  before do
    @user = Factory.create(:user, :email => "bob@aol.com")
    @user.person.save
  end

  describe 'xml' do
    before do
      @message = Factory.create(:status_message, :person => @user.person)
    end

    it 'should serialize to xml with its person' do
      @message.to_xml.to_s.include?(@user.person.diaspora_handle).should == true
    end

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
end

