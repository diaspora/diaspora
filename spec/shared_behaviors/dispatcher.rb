# frozen_string_literal: true

shared_examples "a dispatcher" do
  describe "#dispatch" do
    context "deliver to user services" do
      let(:twitter) { Services::Twitter.new(access_token: "twitter") }

      before do
        alice.services << twitter
      end

      it "delivers a StatusMessage to specified services" do
        opts = {service_types: "Services::Twitter", url: "https://example.org/p/123"}
        expect(Workers::PostToService).to receive(:perform_async).with(twitter.id, post.id, "https://example.org/p/123")
        Diaspora::Federation::Dispatcher.build(alice, post, opts).dispatch
      end

      it "delivers a Retraction of a Post to specified services" do
        opts = {service_types: "Services::Twitter", tweet_id: "123"}
        expect(Workers::DeletePostFromService).to receive(:perform_async).with(twitter.id, opts)

        retraction = Retraction.for(post)
        Diaspora::Federation::Dispatcher.build(alice, retraction, opts).dispatch
      end

      it "does not queue service jobs when no services specified" do
        opts = {url: "https://example.org/p/123"}
        expect(Workers::PostToService).not_to receive(:perform_async)
        Diaspora::Federation::Dispatcher.build(alice, post, opts).dispatch
      end

      it "does not deliver a Comment to services" do
        expect(Workers::PostToService).not_to receive(:perform_async)
        Diaspora::Federation::Dispatcher.build(alice, comment).dispatch
      end

      it "does not deliver a Retraction of a Comment to services" do
        expect(Workers::DeletePostFromService).not_to receive(:perform_async)

        retraction = Retraction.for(comment)
        Diaspora::Federation::Dispatcher.build(alice, retraction).dispatch
      end
    end

    context "deliver to local user" do
      it "queues receive local job for all local receivers" do
        local_subscriber_ids = post.subscribers.select(&:local?).map(&:owner_id)
        expect(Workers::ReceiveLocal).to receive(:perform_async).with("StatusMessage", post.id, local_subscriber_ids)
        Diaspora::Federation::Dispatcher.build(alice, post).dispatch
      end

      it "gets the object for the receiving user" do
        expect(Workers::ReceiveLocal).to receive(:perform_async).with("RSpec::Mocks::Double", 42, [bob.id])

        object = double
        object_to_receive = double
        expect(object).to receive(:subscribers).and_return([bob.person])
        expect(object).to receive(:object_to_receive).and_return(object_to_receive)
        expect(object).to receive(:public?).and_return(post.public?)
        expect(object_to_receive).to receive(:id).and_return(42)

        Diaspora::Federation::Dispatcher.build(alice, object).dispatch
      end

      it "does not queue a job if the object to receive is nil" do
        expect(Workers::ReceiveLocal).not_to receive(:perform_async)

        object = double
        expect(object).to receive(:subscribers).and_return([bob.person])
        expect(object).to receive(:object_to_receive).and_return(nil)
        expect(object).to receive(:public?).and_return(post.public?)

        Diaspora::Federation::Dispatcher.build(alice, object).dispatch
      end

      it "queues receive local job for a specific subscriber" do
        expect(Workers::ReceiveLocal).to receive(:perform_async).with("StatusMessage", post.id, [eve.id])
        Diaspora::Federation::Dispatcher.build(alice, post, subscribers: [eve.person]).dispatch
      end

      it "queues receive local job for a specific subscriber id" do
        expect(Workers::ReceiveLocal).to receive(:perform_async).with("StatusMessage", post.id, [eve.id])
        Diaspora::Federation::Dispatcher.build(alice, post, subscriber_ids: [eve.person.id]).dispatch
      end
    end
  end
end
