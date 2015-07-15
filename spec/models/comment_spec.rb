#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "spec_helper"
require Rails.root.join("spec", "shared_behaviors", "relayable")

describe Comment, :type => :model do
  let(:alices_aspect) { alice.aspects.first }
  let(:status_bob) { bob.post(:status_message, text: "hello", to: bob.aspects.first.id) }
  let(:comment_alice) { alice.comment!(status_bob, "why so formal?") }

  describe 'comment#notification_type' do
    it "returns 'comment_on_post' if the comment is on a post you own" do
      expect(comment_alice.notification_type(bob, alice.person)).to eq(Notifications::CommentOnPost)
    end

    it "returns 'also_commented' if the comment is on a post you participate to" do
      eve.participate! status_bob
      expect(comment_alice.notification_type(eve, alice.person)).to eq(Notifications::AlsoCommented)
    end

    it "returns false if the comment is not on a post you own and no one 'also_commented'" do
      expect(comment_alice.notification_type(eve, alice.person)).to be false
    end

    context "also commented" do
      let(:comment_eve) { eve.comment!(status_bob, "I also commented on the first user's post") }

      before do
        comment_alice
      end

      it "does not return also commented if the user commented" do
        expect(comment_eve.notification_type(eve, alice.person)).to eq(false)
      end

      it "returns 'also_commented' if another person commented on a post you commented on" do
        expect(comment_eve.notification_type(alice, alice.person)).to eq(Notifications::AlsoCommented)
      end
    end
  end

  describe "User#comment" do
    it "should be able to comment on one's own status" do
      bob.comment!(status_bob, "sup dog")
      expect(status_bob.reload.comments.first.text).to eq("sup dog")
    end

    it "should be able to comment on a contact's status" do
      comment_alice
      expect(status_bob.reload.comments.first.text).to eq("why so formal?")
    end

    it "does not multi-post a comment" do
      expect {
        comment_alice
      }.to change { Comment.count }.by(1)
    end
  end

  describe "counter cache" do
    it "increments the counter cache on its post" do
      expect {
        comment_alice
      }.to change{
        status_bob.reload.comments_count
      }.by(1)
    end
  end

  describe "xml" do
    let(:commenter) { create(:user) }
    let(:commenter_aspect) { commenter.aspects.create(name: "bruisers") }
    let(:post) { alice.post :status_message, text: "hello", to: alices_aspect.id }
    let(:comment) { commenter.comment!(post, "Fool!") }
    let(:xml) { comment.to_xml.to_s }

    before do
      connect_users(alice, alices_aspect, commenter, commenter_aspect)
    end

    it "serializes the sender handle" do
      expect(xml.include?(commenter.diaspora_handle)).to be true
    end

    it "serializes the post_guid" do
      expect(xml).to include(post.guid)
    end

    describe "marshalling" do
      let(:marshalled_comment) { Comment.from_xml(xml) }

      it "marshals the author" do
        expect(marshalled_comment.author).to eq(commenter.person)
      end

      it "marshals the post" do
        expect(marshalled_comment.post).to eq(post)
      end

      it "tries to fetch a missing parent" do
        guid = post.guid
        marshalled_comment
        post.destroy
        expect_any_instance_of(Comment).to receive(:fetch_parent).with(guid).and_return(nil)
        Comment.from_xml(xml)
      end
    end
  end

  describe "it is relayable" do
    let(:remote_parent) { build(:status_message, author: remote_raphael) }
    let(:local_parent) { local_luke.post :status_message, text: "hi", to: local_luke.aspects.first }
    let(:object_by_parent_author) { local_luke.comment!(local_parent, "yo!") }
    let(:object_by_recipient) { local_leia.build_comment(text: "yo", post: local_parent) }
    let(:dup_object_by_parent_author) { object_by_parent_author.dup }
    let(:object_on_remote_parent) { local_luke.comment!(remote_parent, "Yeah, it was great") }

    before do
      # shared_behaviors/relayable.rb is still using instance variables, so we need to define them here.
      # Suggestion: refactor all specs using shared_behaviors/relayable.rb to use "let"
      @object_by_parent_author = object_by_parent_author
      @object_by_recipient = object_by_recipient
      @dup_object_by_parent_author = dup_object_by_parent_author
      @object_on_remote_parent = object_on_remote_parent
    end

    let(:build_object) { alice.build_comment(post: status_bob, text: "why so formal?") }
    it_should_behave_like "it is relayable"
  end

  describe "tags" do
    let(:object) { build(:comment) }

    before do
      # shared_behaviors/taggable.rb is still using instance variables, so we need to define them here.
      # Suggestion: refactor all specs using shared_behaviors/taggable.rb to use "let"
      @object = object
    end
    it_should_behave_like "it is taggable"
  end
end
