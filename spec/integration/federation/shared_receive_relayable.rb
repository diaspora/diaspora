shared_examples_for "it deals correctly with a relayable" do
  context "local" do
    let(:entity) { create_relayable_entity(entity_name, local_target, sender_id, nil) }

    it "treats upstream receive correctly" do
      expect(Postzord::Dispatcher).to receive(:build).with(alice, kind_of(klass)).and_call_original
      post_message(generate_xml(entity, sender, recipient), recipient)

      received_entity = klass.find_by(guid: entity.guid)
      expect(received_entity).not_to be_nil
      expect(received_entity.author.diaspora_handle).to eq(remote_user_on_pod_b.diaspora_handle)
    end

    # Checks when a remote pod wants to send us a relayable without having a key for declared diaspora ID
    it "rejects an upstream entity with a malformed author signature" do
      expect(Postzord::Dispatcher).not_to receive(:build)
      allow(remote_user_on_pod_b).to receive(:encryption_key).and_return(OpenSSL::PKey::RSA.new(1024))
      post_message(generate_xml(entity, sender, recipient), recipient)

      expect(klass.exists?(guid: entity.guid)).to be_falsey
    end
  end

  context "remote" do
    let(:author_id) { remote_user_on_pod_c.diaspora_handle }
    let(:entity) { create_relayable_entity(entity_name, remote_target, author_id, sender.encryption_key) }

    it "treats downstream receive correctly" do
      expect(Postzord::Dispatcher).to receive(:build)
                                        .with(alice, kind_of(klass)).and_call_original unless recipient.nil?

      post_message(generate_xml(entity, sender, recipient), recipient)

      received_entity = klass.find_by(guid: entity.guid)
      expect(received_entity).not_to be_nil
      expect(received_entity.author.diaspora_handle).to eq(remote_user_on_pod_c.diaspora_handle)
    end

    # Checks when a remote pod B wants to send us a relayable with authorship from a remote pod C user
    # without having correct signature from him.
    it "rejects a downstream entity with a malformed author signature" do
      expect(Postzord::Dispatcher).not_to receive(:build)
      allow(remote_user_on_pod_c).to receive(:encryption_key).and_return(OpenSSL::PKey::RSA.new(1024))
      post_message(generate_xml(entity, sender, recipient), recipient)

      expect(klass.exists?(guid: entity.guid)).to be_falsey
    end

    # Checks when a remote pod C wants to send us a relayable from its user, but bypassing the pod B where
    # remote status came from.
    it "declines downstream receive when sender signed with a wrong key" do
      expect(Postzord::Dispatcher).not_to receive(:build)
      allow(sender).to receive(:encryption_key).and_return(OpenSSL::PKey::RSA.new(1024))
      post_message(generate_xml(entity, sender, recipient), recipient)

      expect(klass.exists?(guid: entity.guid)).to be_falsey
    end
  end
end
