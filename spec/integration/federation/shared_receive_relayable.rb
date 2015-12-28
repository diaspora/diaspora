shared_examples_for "it deals correctly with a relayable" do
  context "local" do
    let(:entity) {
      FactoryGirl.build(
        entity_name,
        parent_guid: local_message.guid,
        diaspora_id: remote_user_on_pod_b.diaspora_handle
      )
    }

    def mock_private_keys
      allow(DiasporaFederation.callbacks).to receive(:trigger)
                                               .with(:fetch_private_key_by_diaspora_id,
                                                     remote_user_on_pod_b.diaspora_handle)
                                               .and_return(remote_user_on_pod_b.encryption_key)
      allow(DiasporaFederation.callbacks).to receive(:trigger)
                                               .with(:fetch_author_private_key_by_entity_guid, "Post", kind_of(String))
                                               .and_return(nil)
    end

    it "treats upstream receive correctly" do
      mock_private_keys

      Workers::ReceiveEncryptedSalmon.new.perform(alice.id, generate_xml(entity, remote_user_on_pod_b, alice))
      received_entity = klass.find_by(guid: entity.guid)
      expect(received_entity).not_to be_nil
      expect(received_entity.author.diaspora_handle).to eq(remote_user_on_pod_b.person.diaspora_handle)
    end

    # Checks when a remote pod wants to send us a relayable without having a key for declared diaspora ID
    it "rejects an upstream entity with a malformed author signature" do
      allow(remote_user_on_pod_b).to receive(:encryption_key).and_return(OpenSSL::PKey::RSA.new(1024))
      mock_private_keys

      Workers::ReceiveEncryptedSalmon.new.perform(alice.id, generate_xml(entity, remote_user_on_pod_b, alice))
      expect(klass.exists?(guid: entity.guid)).to be(false)
    end
  end

  context "remote parent" do
    let(:entity) {
      FactoryGirl.build(
        entity_name,
        parent_guid: remote_message.guid,
        diaspora_id: remote_user_on_pod_c.diaspora_handle
      )
    }

    def mock_private_keys
      allow(DiasporaFederation.callbacks).to receive(:trigger)
                                                .with(:fetch_private_key_by_diaspora_id,
                                                      remote_user_on_pod_c.diaspora_handle)
                                                .and_return(remote_user_on_pod_c.encryption_key)

      allow(DiasporaFederation.callbacks).to receive(:trigger)
                                                .with(
                                                  :fetch_author_private_key_by_entity_guid,
                                                  "Post",
                                                  remote_message.guid
                                                )
                                                .and_return(remote_user_on_pod_b.encryption_key)
    end

    it "treats downstream receive correctly" do
      mock_private_keys

      Workers::ReceiveEncryptedSalmon.new.perform(alice.id, generate_xml(entity, remote_user_on_pod_b, alice))
      received_entity = klass.find_by(guid: entity.guid)
      expect(received_entity).not_to be_nil
      expect(received_entity.author.diaspora_handle).to eq(remote_user_on_pod_c.diaspora_handle)
    end

    # Checks when a remote pod B wants to send us a relayable with authorship from a remote pod C user
    # without having correct signature from him.
    it "rejects a downstream entity with a malformed author signature" do
      allow(remote_user_on_pod_c).to receive(:encryption_key).and_return(OpenSSL::PKey::RSA.new(1024))
      mock_private_keys

      Workers::ReceiveEncryptedSalmon.new.perform(alice.id, generate_xml(entity, remote_user_on_pod_b, alice))
      expect(klass.exists?(guid: entity.guid)).to be(false)
    end

    # Checks when a remote pod C wants to send us a relayable from its user, but bypassing the pod B where
    # remote status came from.
    it "declines downstream receive when sender signed with a wrong key" do
      allow(remote_user_on_pod_b).to receive(:encryption_key).and_return(OpenSSL::PKey::RSA.new(1024))
      mock_private_keys

      Workers::ReceiveEncryptedSalmon.new.perform(alice.id, generate_xml(entity, remote_user_on_pod_b, alice))
      expect(klass.exists?(guid: entity.guid)).to be(false)
    end
  end
end
