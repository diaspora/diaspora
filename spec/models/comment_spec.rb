#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require Rails.root.join("spec", "shared_behaviors", "relayable")

describe Comment do
  before do
    @alices_aspect = alice.aspects.first
    @status = bob.post(:status_message, :text => "hello", :to => bob.aspects.first.id)
  end

  describe 'comment#notification_type' do
    it "returns 'comment_on_post' if the comment is on a post you own" do
      comment = alice.comment!(@status, "why so formal?")
      comment.notification_type(bob, alice.person).should == Notifications::CommentOnPost
    end

    it 'returns false if the comment is not on a post you own and no one "also_commented"' do
      comment = alice.comment!(@status, "I simply felt like issuing a greeting.  Do step off.")
      comment.notification_type(eve, alice.person).should be_false
    end

    context "also commented" do
      before do
        alice.comment!(@status, "a-commenta commenta")
        @comment = eve.comment!(@status, "I also commented on the first user's post")
      end

      it 'does not return also commented if the user commented' do
        @comment.notification_type(eve, alice.person).should == false
      end

      it "returns 'also_commented' if another person commented on a post you commented on" do
        @comment.notification_type(alice, alice.person).should == Notifications::AlsoCommented
      end
    end
  end

  describe 'User#comment' do
    it "should be able to comment on one's own status" do
      alice.comment!(@status, "Yeah, it was great")
      @status.reload.comments.first.text.should == "Yeah, it was great"
    end

    it "should be able to comment on a contact's status" do
      bob.comment!(@status, "sup dog")
      @status.reload.comments.first.text.should == "sup dog"
    end

    it 'does not multi-post a comment' do
      lambda {
        alice.comment!(@status, 'hello')
      }.should change { Comment.count }.by(1)
    end
  end

  describe 'counter cache' do
    it 'increments the counter cache on its post' do
      lambda {
        alice.comment!(@status, "oh yeah")
      }.should change{
        @status.reload.comments_count
      }.by(1)
    end
  end

  describe 'xml' do
    before do
      @commenter = FactoryGirl.create(:user)
      @commenter_aspect = @commenter.aspects.create(:name => "bruisers")
      connect_users(alice, @alices_aspect, @commenter, @commenter_aspect)
      @post = alice.post :status_message, :text => "hello", :to => @alices_aspect.id
      @comment = @commenter.comment!(@post, "Fool!")
      @xml = @comment.to_xml.to_s
    end

    it 'serializes the sender handle' do
      @xml.include?(@commenter.diaspora_handle).should be_true
    end

    it 'serializes the post_guid' do
      @xml.should include(@post.guid)
    end

    describe 'marshalling' do
      before do
        @marshalled_comment = Comment.from_xml(@xml)
      end

      it 'marshals the author' do
        @marshalled_comment.author.should == @commenter.person
      end

      it 'marshals the post' do
        @marshalled_comment.post.should == @post
      end
    end
  end

  describe 'it is relayable' do
    before do
      @local_luke, @local_leia, @remote_raphael = set_up_friends
      @remote_parent = FactoryGirl.build(:status_message, :author => @remote_raphael)
      @local_parent = @local_luke.post :status_message, :text => "hi", :to => @local_luke.aspects.first

      @object_by_parent_author = @local_luke.comment!(@local_parent, "yo")
      @object_by_recipient = @local_leia.build_comment(:text => "yo", :post => @local_parent)
      @dup_object_by_parent_author = @object_by_parent_author.dup

      @object_on_remote_parent = @local_luke.comment!(@remote_parent, "Yeah, it was great")
    end

    let(:build_object) { alice.build_comment(:post => @status, :text => "why so formal?") }
    it_should_behave_like 'it is relayable'
  end

  describe 'tags' do
    before do
      @object = FactoryGirl.build(:comment)
    end
    it_should_behave_like 'it is taggable'
  end

end
