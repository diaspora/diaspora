#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "spec_helper"
require Rails.root.join("spec", "shared_behaviors", "relayable")

describe Comment, :type => :model do
  let(:alices_aspect) { alice.aspects.first }
  let(:status_bob) { bob.post(:status_message, text: "hello", to: bob.aspects.first.id) }
  let(:comment_alice) { alice.comment!(status_bob, "why so formal?") }

  describe "#destroy" do
    it "should delete a participation" do
      comment_alice
      expect { comment_alice.destroy }.to change { Participation.count }.by(-1)
    end

    it "should decrease count participation" do
      alice.comment!(status_bob, "Are you there?")
      comment_alice.destroy
      participations = Participation.where(target_id: comment_alice.commentable_id, author_id: comment_alice.author_id)
      expect(participations.first.count).to eq(1)
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

    it "should create a participation" do
      comment_alice
      participations = Participation.where(target_id: comment_alice.commentable_id, author_id: comment_alice.author_id)
      expect(participations.count).to eq(1)
    end

    it "does not create a participation if comment validation failed" do
      begin
        alice.comment!(status_bob, " ")
      rescue ActiveRecord::RecordInvalid
      end
      participations = Participation.where(target_id: status_bob, author_id: alice.person.id)
      expect(participations.count).to eq(0)
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
