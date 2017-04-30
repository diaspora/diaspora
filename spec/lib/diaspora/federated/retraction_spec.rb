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
      federation_retraction_data = Diaspora::Federation::Entities.retraction_data_for(post)

      expect(retraction.data).to eq(federation_retraction_data)
    end
  end

  describe ".for" do
    it "creates a retraction for a post" do
      expect(Diaspora::Federation::Entities).to receive(:retraction_data_for).with(post)

      Retraction.for(post)
    end

    it "creates a retraction for a relayable" do
      comment = FactoryGirl.create(:comment, author: alice.person, post: post)

      expect(Diaspora::Federation::Entities).to receive(:retraction_data_for).with(comment)

      Retraction.for(comment)
    end

    it "creates a retraction for a contact" do
      contact = FactoryGirl.create(:contact)

      expect(Diaspora::Federation::Entities).to receive(:retraction_data_for).with(contact)

      Retraction.for(contact)
    end
  end

  describe ".defer_dispatch" do
    it "queues a job to send the retraction later" do
      post = local_luke.post(:status_message, text: "destroy!", public: true)
      retraction = Retraction.for(post)
      federation_retraction = Diaspora::Federation::Entities.retraction(retraction)

      expect(Workers::DeferredRetraction).to receive(:perform_async).with(
        local_luke.id, federation_retraction.to_h, [remote_raphael.id], service_types: []
      )

      retraction.defer_dispatch(local_luke)
    end

    it "adds service metadata to queued job for deletion" do
      post.tweet_id = "123"
      twitter = Services::Twitter.new(access_token: "twitter")
      facebook = Services::Facebook.new(access_token: "facebook")
      alice.services << twitter << facebook

      retraction = Retraction.for(post)
      federation_retraction = Diaspora::Federation::Entities.retraction(retraction)

      expect(Workers::DeferredRetraction).to receive(:perform_async).with(
        alice.id, federation_retraction.to_h, [], service_types: ["Services::Twitter"], tweet_id: "123"
      )

      retraction.defer_dispatch(alice)
    end

    it "queues also a job if subscribers is empty" do
      retraction = Retraction.for(post)
      federation_retraction = Diaspora::Federation::Entities.retraction(retraction)

      expect(Workers::DeferredRetraction).to receive(:perform_async).with(
        alice.id, federation_retraction.to_h, [], service_types: []
      )

      retraction.defer_dispatch(alice)
    end

    it "queues a job with empty opts for non-StatusMessage" do
      post = local_luke.post(:status_message, text: "hello", public: true)
      comment = local_luke.comment!(post, "destroy!")
      retraction = Retraction.for(comment)
      federation_retraction = Diaspora::Federation::Entities.retraction(retraction)

      expect(Workers::DeferredRetraction).to receive(:perform_async).with(
        local_luke.id, federation_retraction.to_h, [remote_raphael.id], {}
      )

      retraction.defer_dispatch(local_luke)
    end

    it "uses the author of the target parent as sender for a comment-retraction if the parent is local" do
      post = local_luke.post(:status_message, text: "hello", public: true)
      comment = local_leia.comment!(post, "destroy!")
      federation_retraction = Diaspora::Federation::Entities.retraction(comment)

      expect(Workers::DeferredRetraction).to receive(:perform_async).with(
        local_luke.id, federation_retraction.to_h, [remote_raphael.id], {}
      )

      Retraction.for(comment).defer_dispatch(local_leia)
    end

    context "relayable" do
      let(:post) { local_luke.post(:status_message, text: "hello", public: true) }
      let(:comment) { FactoryGirl.create(:comment, post: post, author: remote_raphael) }

      it "sends retraction to target author if deleted by parent author" do
        retraction = Retraction.for(comment)
        federation_retraction = Diaspora::Federation::Entities.retraction(retraction)

        expect(Workers::DeferredRetraction).to receive(:perform_async).with(
          local_luke.id, federation_retraction.to_h, [remote_raphael.id], {}
        )

        retraction.defer_dispatch(local_luke)
      end

      it "don't sends retraction back to target author if relayed by parent author" do
        retraction = Retraction.for(comment)
        federation_retraction = Diaspora::Federation::Entities.retraction(retraction)

        expect(Workers::DeferredRetraction).to receive(:perform_async).with(
          local_luke.id, federation_retraction.to_h, [], {}
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

    it "returns false for a public comment if parent post is not local" do
      remote_post = FactoryGirl.create(:status_message, author: remote_raphael)
      comment = alice.comment!(remote_post, "destroy!")
      expect(Retraction.for(comment).public?).to be_falsey
    end

    it "returns false for a private target" do
      private_post = alice.post(:status_message, text: "destroy!", to: alice.aspects.first.id)
      expect(Retraction.for(private_post).public?).to be_falsey
    end
  end
end
