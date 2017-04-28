#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Retraction do
  let(:post) { alice.post(:status_message, text: "destroy!", public: true) }
  let(:retraction) { Retraction.for(post, alice) }

  describe "#subscribers" do
    it "contains all remote-subscribers of target object" do
      post = local_luke.post(:status_message, text: "destroy!", public: true)

      retraction = Retraction.for(post, local_luke)

      expect(retraction.subscribers).to eq([remote_raphael])
    end
  end

  describe "#data" do
    it "contains the hash with all data from the federation-retraction" do
      federation_retraction = Diaspora::Federation::Entities.signed_retraction(post, alice)

      expect(retraction.data).to eq(federation_retraction.to_h)
    end
  end

  describe ".for" do
    it "creates a retraction for a post" do
      expect(Diaspora::Federation::Entities).to receive(:signed_retraction).with(post, alice)

      Retraction.for(post, alice)
    end

    it "creates a retraction for a relayable" do
      comment = FactoryGirl.create(:comment, author: alice.person, post: post)

      expect(Diaspora::Federation::Entities).to receive(:relayable_retraction).with(comment, alice)

      Retraction.for(comment, alice)
    end

    it "creates a retraction for a contact" do
      contact = FactoryGirl.create(:contact)

      expect(Diaspora::Federation::Entities).to receive(:retraction).with(contact)

      Retraction.for(contact, contact.user)
    end
  end

  describe ".defer_dispatch" do
    it "queues a job to send the retraction later" do
      post = local_luke.post(:status_message, text: "destroy!", public: true)
      federation_retraction = Diaspora::Federation::Entities.signed_retraction(post, local_luke)

      expect(Workers::DeferredRetraction).to receive(:perform_async).with(
        local_luke.id, federation_retraction.to_h, [remote_raphael.id], service_types: []
      )

      Retraction.for(post, local_luke).defer_dispatch(local_luke)
    end

    it "adds service metadata to queued job for deletion" do
      post.tweet_id = "123"
      twitter = Services::Twitter.new(access_token: "twitter")
      facebook = Services::Facebook.new(access_token: "facebook")
      alice.services << twitter << facebook

      federation_retraction = Diaspora::Federation::Entities.signed_retraction(post, alice)

      expect(Workers::DeferredRetraction).to receive(:perform_async).with(
        alice.id, federation_retraction.to_h, [], service_types: ["Services::Twitter"], tweet_id: "123"
      )

      Retraction.for(post, alice).defer_dispatch(alice)
    end

    it "queues also a job if subscribers is empty" do
      federation_retraction = Diaspora::Federation::Entities.signed_retraction(post, alice)

      expect(Workers::DeferredRetraction).to receive(:perform_async).with(
        alice.id, federation_retraction.to_h, [], service_types: []
      )

      Retraction.for(post, alice).defer_dispatch(alice)
    end

    it "queues a job with empty opts for non-StatusMessage" do
      post = local_luke.post(:status_message, text: "hello", public: true)
      comment = local_luke.comment!(post, "destroy!")
      federation_retraction = Diaspora::Federation::Entities.relayable_retraction(comment, local_luke)

      expect(Workers::DeferredRetraction).to receive(:perform_async).with(
        local_luke.id, federation_retraction.to_h, [remote_raphael.id], {}
      )

      Retraction.for(comment, local_luke).defer_dispatch(local_luke)
    end

    it "uses the author of the target parent as sender for a comment-retraction if the parent is local" do
      post = local_luke.post(:status_message, text: "hello", public: true)
      comment = local_leia.comment!(post, "destroy!")
      federation_retraction = Diaspora::Federation::Entities.relayable_retraction(comment, local_leia)

      expect(Workers::DeferredRetraction).to receive(:perform_async).with(
        local_luke.id, federation_retraction.to_h, [remote_raphael.id], {}
      )

      Retraction.for(comment, local_leia).defer_dispatch(local_leia)
    end

    context "relayable" do
      let(:post) { local_luke.post(:status_message, text: "hello", public: true) }
      let(:comment) { FactoryGirl.create(:comment, post: post, author: remote_raphael) }

      it "sends retraction to target author if deleted by parent author" do
        federation_retraction = Diaspora::Federation::Entities.relayable_retraction(comment, local_luke)

        expect(Workers::DeferredRetraction).to receive(:perform_async).with(
          local_luke.id, federation_retraction.to_h, [remote_raphael.id], {}
        )

        Retraction.for(comment, local_luke).defer_dispatch(local_luke)
      end

      it "don't sends retraction back to target author if relayed by parent author" do
        federation_retraction = Diaspora::Federation::Entities.relayable_retraction(comment, local_luke)

        expect(Workers::DeferredRetraction).to receive(:perform_async).with(
          local_luke.id, federation_retraction.to_h, [], {}
        )

        Retraction.for(comment, local_luke).defer_dispatch(local_luke, false)
      end
    end
  end

  describe "#perform" do
    it "destroys the target object" do
      expect(post).to receive(:destroy!)
      Retraction.for(post, alice).perform
    end
  end

  describe "#public?" do
    it "returns true for a public post" do
      expect(Retraction.for(post, alice).public?).to be_truthy
    end

    it "returns true for a public comment if parent post is local" do
      comment = bob.comment!(post, "destroy!")
      expect(Retraction.for(comment, bob).public?).to be_truthy
    end

    it "returns false for a public comment if parent post is not local" do
      remote_post = FactoryGirl.create(:status_message, author: remote_raphael)
      comment = alice.comment!(remote_post, "destroy!")
      expect(Retraction.for(comment, alice).public?).to be_falsey
    end

    it "returns false for a private target" do
      private_post = alice.post(:status_message, text: "destroy!", to: alice.aspects.first.id)
      expect(Retraction.for(private_post, alice).public?).to be_falsey
    end
  end
end
