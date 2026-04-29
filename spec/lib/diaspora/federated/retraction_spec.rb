# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Diaspora::Federated::Retraction do
  let(:post) { alice.post(:status_message, text: "destroy!", public: true) }
  let(:retraction) { described_class.for(post) }

  describe "#subscribers" do
    it "contains all remote-subscribers of target object" do
      post = local_luke.post(:status_message, text: "destroy!", public: true)

      retraction = described_class.for(post)

      expect(retraction.subscribers).to eq([remote_raphael])
    end
  end

  describe "#data" do
    it "contains the hash with all data from the federation-retraction" do
      expect(retraction.data[:target_guid]).to eq(post.guid)
      expect(retraction.data[:target]).to eq(Diaspora::Federation::Entities.related_entity(post).to_h)
      expect(retraction.data[:target_type]).to eq("Post")
      expect(retraction.data[:author]).to eq(alice.diaspora_handle)
    end
  end

  describe ".retraction_data_for" do
    it "creates the retraction data for a post" do
      data = described_class.retraction_data_for(post)
      expect(data[:target_guid]).to eq(post.guid)
      expect(data[:target]).to eq(Diaspora::Federation::Entities.related_entity(post).to_h)
      expect(data[:target_type]).to eq("Post")
      expect(data[:author]).to eq(alice.diaspora_handle)
    end

    it "creates the retraction data for a relayable" do
      comment = FactoryBot.create(:comment, author: alice.person, post: post)

      data = described_class.retraction_data_for(comment)
      expect(data[:target_guid]).to eq(comment.guid)
      expect(data[:target]).to eq(Diaspora::Federation::Entities.related_entity(comment).to_h)
      expect(data[:target_type]).to eq("Comment")
      expect(data[:author]).to eq(alice.diaspora_handle)
    end
  end

  describe ".for" do
    it "creates a retraction for a post" do
      expect(described_class).to receive(:retraction_data_for).with(post)

      described_class.for(post)
    end

    it "creates a retraction for a relayable" do
      comment = FactoryBot.create(:comment, author: alice.person, post: post)

      expect(described_class).to receive(:retraction_data_for).with(comment)

      described_class.for(comment)
    end
  end

  describe ".defer_dispatch" do
    it "queues a job to send the retraction later" do
      post = local_luke.post(:status_message, text: "destroy!", public: true)
      retraction = described_class.for(post)
      federation_retraction = Diaspora::Federation::Entities.retraction(retraction)

      expect(Workers::DeferredRetraction).to receive(:perform_async).with(
        local_luke.id, "Diaspora::Federated::Retraction", federation_retraction.to_h.deep_stringify_keys,
        [remote_raphael.id]
      )

      retraction.defer_dispatch(local_luke)
    end

    it "queues a job for non-StatusMessage" do
      post = local_luke.post(:status_message, text: "hello", public: true)
      comment = local_luke.comment!(post, "destroy!")
      retraction = described_class.for(comment)
      federation_retraction = Diaspora::Federation::Entities.retraction(retraction)

      expect(Workers::DeferredRetraction).to receive(:perform_async).with(
        local_luke.id, "Diaspora::Federated::Retraction", federation_retraction.to_h.deep_stringify_keys,
        [remote_raphael.id]
      )

      retraction.defer_dispatch(local_luke)
    end

    context "relayable" do
      let(:post) { local_luke.post(:status_message, text: "hello", public: true) }
      let(:comment) { FactoryBot.create(:comment, post: post, author: remote_raphael) }

      it "sends retraction to target author if deleted by parent author" do
        retraction = described_class.for(comment)
        federation_retraction = Diaspora::Federation::Entities.retraction(retraction)

        expect(Workers::DeferredRetraction).to receive(:perform_async).with(
          local_luke.id, "Diaspora::Federated::Retraction", federation_retraction.to_h.deep_stringify_keys,
          [remote_raphael.id]
        )

        retraction.defer_dispatch(local_luke)
      end

      it "don't sends retraction back to target author if relayed by parent author" do
        retraction = described_class.for(comment)
        federation_retraction = Diaspora::Federation::Entities.retraction(retraction)

        expect(Workers::DeferredRetraction).to receive(:perform_async).with(
          local_luke.id, "Diaspora::Federated::Retraction", federation_retraction.to_h.deep_stringify_keys, []
        )

        retraction.defer_dispatch(local_luke, false)
      end
    end
  end

  describe "#perform" do
    it "destroys the target object" do
      expect(post).to receive(:destroy!)
      described_class.for(post).perform
    end
  end

  describe "#public?" do
    it "returns true for a public post" do
      expect(described_class.for(post).public?).to be_truthy
    end

    it "returns true for a public comment if parent post is local" do
      comment = bob.comment!(post, "destroy!")
      expect(described_class.for(comment).public?).to be_truthy
    end

    it "returns true for a public comment if parent post is not local" do
      remote_post = FactoryBot.create(:status_message, author: remote_raphael, public: true)
      comment = alice.comment!(remote_post, "destroy!")
      expect(described_class.for(comment).public?).to be_truthy
    end

    it "returns false for a private target" do
      private_post = alice.post(:status_message, text: "destroy!", to: alice.aspects.first.id)
      expect(described_class.for(private_post).public?).to be_falsey
    end
  end
end
