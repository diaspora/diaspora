# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Retraction do
  let(:post) { alice.post(:status_message, text: "destroy!", public: true) }
  let(:retraction) { Retraction.for(post) }

  describe "#subscribers" do
    it "contains all remote-subscribers of target object" do
      post = local_luke.post(:status_message, text: "destroy!", public: true)

      retraction = Retraction.for(post)

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
      data = Retraction.retraction_data_for(post)
      expect(data[:target_guid]).to eq(post.guid)
      expect(data[:target]).to eq(Diaspora::Federation::Entities.related_entity(post).to_h)
      expect(data[:target_type]).to eq("Post")
      expect(data[:author]).to eq(alice.diaspora_handle)
    end

    it "creates the retraction data for a relayable" do
      comment = FactoryGirl.create(:comment, author: alice.person, post: post)

      data = Retraction.retraction_data_for(comment)
      expect(data[:target_guid]).to eq(comment.guid)
      expect(data[:target]).to eq(Diaspora::Federation::Entities.related_entity(comment).to_h)
      expect(data[:target_type]).to eq("Comment")
      expect(data[:author]).to eq(alice.diaspora_handle)
    end
  end

  describe ".for" do
    it "creates a retraction for a post" do
      expect(Retraction).to receive(:retraction_data_for).with(post)

      Retraction.for(post)
    end

    it "creates a retraction for a relayable" do
      comment = FactoryGirl.create(:comment, author: alice.person, post: post)

      expect(Retraction).to receive(:retraction_data_for).with(comment)

      Retraction.for(comment)
    end
  end

  describe ".defer_dispatch" do
    it "queues a job to send the retraction later" do
      post = local_luke.post(:status_message, text: "destroy!", public: true)
      retraction = Retraction.for(post)
      federation_retraction = Diaspora::Federation::Entities.retraction(retraction)

      expect(Workers::DeferredRetraction).to receive(:perform_async).with(
        local_luke.id, "Retraction", federation_retraction.to_h, [remote_raphael.id], service_types: []
      )

      retraction.defer_dispatch(local_luke)
    end

    it "adds service metadata to queued job for deletion" do
      post.tweet_id = "123"
      twitter = Services::Twitter.new(access_token: "twitter")
      alice.services << twitter

      retraction = Retraction.for(post)
      federation_retraction = Diaspora::Federation::Entities.retraction(retraction)

      expect(Workers::DeferredRetraction).to receive(:perform_async).with(
        alice.id, "Retraction", federation_retraction.to_h, [], service_types: ["Services::Twitter"], tweet_id: "123"
      )

      retraction.defer_dispatch(alice)
    end

    it "queues also a job if subscribers is empty" do
      retraction = Retraction.for(post)
      federation_retraction = Diaspora::Federation::Entities.retraction(retraction)

      expect(Workers::DeferredRetraction).to receive(:perform_async).with(
        alice.id, "Retraction", federation_retraction.to_h, [], service_types: []
      )

      retraction.defer_dispatch(alice)
    end

    it "queues a job with empty opts for non-StatusMessage" do
      post = local_luke.post(:status_message, text: "hello", public: true)
      comment = local_luke.comment!(post, "destroy!")
      retraction = Retraction.for(comment)
      federation_retraction = Diaspora::Federation::Entities.retraction(retraction)

      expect(Workers::DeferredRetraction).to receive(:perform_async).with(
        local_luke.id, "Retraction", federation_retraction.to_h, [remote_raphael.id], {}
      )

      retraction.defer_dispatch(local_luke)
    end

    context "relayable" do
      let(:post) { local_luke.post(:status_message, text: "hello", public: true) }
      let(:comment) { FactoryGirl.create(:comment, post: post, author: remote_raphael) }

      it "sends retraction to target author if deleted by parent author" do
        retraction = Retraction.for(comment)
        federation_retraction = Diaspora::Federation::Entities.retraction(retraction)

        expect(Workers::DeferredRetraction).to receive(:perform_async).with(
          local_luke.id, "Retraction", federation_retraction.to_h, [remote_raphael.id], {}
        )

        retraction.defer_dispatch(local_luke)
      end

      it "don't sends retraction back to target author if relayed by parent author" do
        retraction = Retraction.for(comment)
        federation_retraction = Diaspora::Federation::Entities.retraction(retraction)

        expect(Workers::DeferredRetraction).to receive(:perform_async).with(
          local_luke.id, "Retraction", federation_retraction.to_h, [], {}
        )

        retraction.defer_dispatch(local_luke, false)
      end
    end
  end

  describe "#perform" do
    it "destroys the target object" do
      expect(post).to receive(:destroy!)
      Retraction.for(post).perform
    end
  end

  describe "#public?" do
    it "returns true for a public post" do
      expect(Retraction.for(post).public?).to be_truthy
    end

    it "returns true for a public comment if parent post is local" do
      comment = bob.comment!(post, "destroy!")
      expect(Retraction.for(comment).public?).to be_truthy
    end

    it "returns true for a public comment if parent post is not local" do
      remote_post = FactoryGirl.create(:status_message, author: remote_raphael, public: true)
      comment = alice.comment!(remote_post, "destroy!")
      expect(Retraction.for(comment).public?).to be_truthy
    end

    it "returns false for a private target" do
      private_post = alice.post(:status_message, text: "destroy!", to: alice.aspects.first.id)
      expect(Retraction.for(private_post).public?).to be_falsey
    end
  end
end
