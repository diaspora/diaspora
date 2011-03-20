#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, "spec", "shared_behaviors", "relayable")

describe Like do
  before do
    @alices_aspect = alice.aspects.first
    @bobs_aspect = bob.aspects.first

    @bob = bob
    @eve = eve
    @status = alice.post(:status_message, :text => "hello", :to => @alices_aspect.id)
  end

  describe 'User#like' do
    it "should be able to like on one's own status" do
      alice.like(1, :on => @status)
      @status.reload.likes.first.positive.should == true
    end

    it "should be able to like on a contact's status" do
      bob.like(0, :on => @status)
      @status.reload.dislikes.first.positive.should == false
    end

    it "does not allow multiple likes" do
      lambda {
        alice.like(1, :on => @status)
        alice.like(0, :on => @status)
      }.should raise_error
    end
  end

  describe 'xml' do
    before do
      @liker = Factory.create(:user)
      @liker_aspect = @liker.aspects.create(:name => "dummies")
      connect_users(alice, @alices_aspect, @liker, @liker_aspect)
      @post = alice.post :status_message, :text => "huhu", :to => @alices_aspect.id
      @like = @liker.like 0, :on => @post
      @xml = @like.to_xml.to_s
    end
    it 'serializes the sender handle' do
      @xml.include?(@liker.diaspora_handle).should be_true
    end
    it' serializes the post_guid' do
      @xml.should include(@post.guid)
    end
    describe 'marshalling' do
      before do
        @marshalled_like = Like.from_xml(@xml)
      end
      it 'marshals the author' do
        @marshalled_like.author.should == @liker.person
      end
      it 'marshals the post' do
        @marshalled_like.post.should == @post
      end
    end
  end

  describe 'it is relayable' do
    before do
      @local_luke, @local_leia, @remote_raphael = set_up_friends
      @remote_parent = Factory.create(:status_message, :author => @remote_raphael)
      @local_parent = @local_luke.post :status_message, :text => "foobar", :to => @local_luke.aspects.first
    
      @object_by_parent_author = @local_luke.like(1, :on => @local_parent)
      @object_by_recipient = @local_leia.build_like(1, :on => @local_parent)
      @dup_object_by_parent_author = @object_by_parent_author.dup
    
      @object_on_remote_parent = @local_luke.like(0, :on => @remote_parent)
    end
    it_should_behave_like 'it is relayable'
  end

end
