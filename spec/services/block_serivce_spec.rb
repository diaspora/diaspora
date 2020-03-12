# frozen_string_literal: true

describe BlockService do
  describe "#block" do
    let(:service) { BlockService.new(alice) }

    it "calls disconnect if there is a contact for a given user" do
      contact = alice.contact_for(bob.person)
      expect(alice).to receive(:contact_for).and_return(contact)
      expect(alice).to receive(:disconnect).with(contact)
      expect(Diaspora::Federation::Dispatcher).not_to receive(:defer_dispatch)
      service.block(bob.person)
    end

    it "queues a message with the block if the person is remote and there is no contact for a given user" do
      expect(alice).not_to receive(:disconnect)
      expect(Diaspora::Federation::Dispatcher).to receive(:defer_dispatch)
      service.block(remote_raphael)
    end

    it "does nothing if the person is local and there is no contact for a given user" do
      expect(alice).not_to receive(:disconnect)
      expect(Diaspora::Federation::Dispatcher).not_to receive(:defer_dispatch)
      service.block(eve.person)
    end
  end
end
