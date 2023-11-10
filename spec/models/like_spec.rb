# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Like, type: :model do
  let(:status) { bob.post(:status_message, text: "hello", to: bob.aspects.first.id) }

  it "has a valid factory" do
    expect(FactoryBot.build(:like)).to be_valid
  end

  describe "#destroy" do
    let!(:like) { alice.like!(status) }

    it "should delete a participation" do
      expect { like.destroy }.to change { Participation.count }.by(-1)
    end

    it "should decrease count participation" do
      alice.comment!(status, "Are you there?")
      like.destroy
      participations = Participation.where(target_id: status.id, author_id: like.author_id)
      expect(participations.first.count).to eq(1)
    end

    context "on comment" do
      let(:comment) { bob.comment!(status, "Are you there?") }
      let!(:like) { alice.like_comment!(comment) }

      it "should delete a participation" do
        expect { like.destroy }.to change { Participation.count }.by(-1)
      end

      it "should decrease count participation" do
        alice.comment!(status, "Yes, I am here!")
        like.destroy
        participations = Participation.where(target_id: status.id, author_id: like.author_id)
        expect(participations.first.count).to eq(1)
      end
    end
  end

  describe "counter cache" do
    it "increments the counter cache on its post" do
      expect {
        alice.like!(status)
      }.to change { status.reload.likes_count }.by(1)
    end

    it "increments the counter cache on its comment" do
      comment = FactoryBot.create(:comment, post: status)
      expect {
        alice.like!(comment)
      }.to change { comment.reload.likes_count }.by(1)
    end
  end

  describe "interacted_at" do
    it "doesn't change the interacted at timestamp of the parent" do
      interacted_at = status.reload.interacted_at.to_i

      Timecop.travel(Time.zone.now + 1.minute) do
        Like::Generator.new(alice, status).build.save
        expect(status.reload.interacted_at.to_i).to eq(interacted_at)
      end
    end
  end

  it_behaves_like "it is relayable" do
    let(:remote_parent) { FactoryBot.create(:status_message, author: remote_raphael) }
    let(:local_parent) { local_luke.post(:status_message, text: "hi", to: local_luke.aspects.first) }
    let(:object_on_local_parent) { local_luke.like!(local_parent) }
    let(:object_on_remote_parent) { local_luke.like!(remote_parent) }
    let(:remote_object_on_local_parent) { FactoryBot.create(:like, target: local_parent, author: remote_raphael) }
    let(:relayable) { Like::Generator.new(alice, status).build }
  end

  context "like for a comment" do
    it_behaves_like "it is relayable" do
      let(:local_parent) { local_luke.post(:status_message, text: "hi", to: local_luke.aspects.first) }
      let(:remote_parent) { FactoryBot.create(:status_message, author: remote_raphael) }
      let(:comment_on_local_parent) { FactoryBot.create(:comment, post: local_parent) }
      let(:comment_on_remote_parent) { FactoryBot.create(:comment, post: remote_parent) }
      let(:object_on_local_parent) { local_luke.like!(comment_on_local_parent) }
      let(:object_on_remote_parent) { local_luke.like!(comment_on_remote_parent) }
      let(:remote_object_on_local_parent) { FactoryBot.create(:like, target: local_parent, author: remote_raphael) }
      let(:relayable) { Like::Generator.new(alice, status).build }
    end
  end
end
