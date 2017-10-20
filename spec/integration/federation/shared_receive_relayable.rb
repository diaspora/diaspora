# frozen_string_literal: true

shared_examples_for "it deals correctly with a relayable" do
  context "local" do
    let(:entity) { create_relayable_entity(entity_name, local_parent, sender_id) }

    it "treats upstream receive correctly" do
      expect(Workers::ReceiveLocal).to receive(:perform_async)
      post_message(generate_payload(entity, sender, recipient), recipient)

      received_entity = klass.find_by(guid: entity.guid)
      expect(received_entity).not_to be_nil
      expect(received_entity.author.diaspora_handle).to eq(remote_user_on_pod_b.diaspora_handle)
    end

    # Checks when a remote pod wants to send us a relayable without having a key for declared diaspora ID
    it "rejects an upstream entity with a malformed author signature" do
      expect(Workers::ReceiveLocal).not_to receive(:perform_async)
      allow(remote_user_on_pod_b).to receive(:encryption_key).and_return(OpenSSL::PKey::RSA.new(1024))
      post_message(generate_payload(entity, sender, recipient), recipient)

      expect(klass.exists?(guid: entity.guid)).to be_falsey
    end
  end

  context "remote" do
    let(:author_id) { remote_user_on_pod_c.diaspora_handle }
    let(:entity) { create_relayable_entity(entity_name, remote_parent, author_id) }

    it "treats downstream receive correctly" do
      expect(Workers::ReceiveLocal).to receive(:perform_async)

      post_message(generate_payload(entity, sender, recipient), recipient)

      received_entity = klass.find_by(guid: entity.guid)
      expect(received_entity).not_to be_nil
      expect(received_entity.author.diaspora_handle).to eq(remote_user_on_pod_c.diaspora_handle)
    end

    # Checks when a remote pod B wants to send us a relayable with authorship from a remote pod C user
    # without having a correct signature for them.
    it "rejects a downstream entity with a malformed author signature" do
      expect(Workers::ReceiveLocal).not_to receive(:perform_async)
      allow(remote_user_on_pod_c).to receive(:encryption_key).and_return(OpenSSL::PKey::RSA.new(1024))
      post_message(generate_payload(entity, sender, recipient), recipient)

      expect(klass.exists?(guid: entity.guid)).to be_falsey
    end

    # Checks when a remote pod C wants to send us a relayable from its user, but bypassing the pod B where
    # remote status came from.
    it "declines downstream receive when sender signed with a wrong key" do
      expect(Workers::ReceiveLocal).not_to receive(:perform_async)
      allow(sender).to receive(:encryption_key).and_return(OpenSSL::PKey::RSA.new(1024))
      post_message(generate_payload(entity, sender, recipient), recipient)

      expect(klass.exists?(guid: entity.guid)).to be_falsey
    end
  end
end
