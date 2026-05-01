# frozen_string_literal: true

shared_examples "a dispatcher" do
  describe "#dispatch" do
    context "deliver to local user" do
      it "queues receive local job for all local receivers" do
        local_subscriber_ids = post.subscribers.select(&:local?).map(&:owner_id)
        expect(ReceiveLocalWorker).to receive(:perform_async).with("StatusMessage", post.id, local_subscriber_ids)
        Diaspora::Federation::Dispatcher.build(alice, post).dispatch
      end

      it "gets the object for the receiving user" do
        expect(ReceiveLocalWorker).to receive(:perform_async).with("RSpec::Mocks::Double", 42, [bob.id])

        object = double
        object_to_receive = double
        expect(object).to receive(:subscribers).and_return([bob.person])
        expect(object).to receive(:object_to_receive).and_return(object_to_receive)
        expect(object).to receive(:public?).and_return(post.public?)
        expect(object_to_receive).to receive(:id).and_return(42)

        Diaspora::Federation::Dispatcher.build(alice, object).dispatch
      end

      it "does not queue a job if the object to receive is nil" do
        expect(ReceiveLocalWorker).not_to receive(:perform_async)

        object = double
        expect(object).to receive(:subscribers).and_return([bob.person])
        expect(object).to receive(:object_to_receive).and_return(nil)
        expect(object).to receive(:public?).and_return(post.public?)

        Diaspora::Federation::Dispatcher.build(alice, object).dispatch
      end

      it "queues receive local job for a specific subscriber" do
        expect(ReceiveLocalWorker).to receive(:perform_async).with("StatusMessage", post.id, [eve.id])
        Diaspora::Federation::Dispatcher.build(alice, post, subscribers: [eve.person]).dispatch
      end

      it "queues receive local job for a specific subscriber id" do
        expect(ReceiveLocalWorker).to receive(:perform_async).with("StatusMessage", post.id, [eve.id])
        Diaspora::Federation::Dispatcher.build(alice, post, subscriber_ids: [eve.person.id]).dispatch
      end
    end
  end
end
