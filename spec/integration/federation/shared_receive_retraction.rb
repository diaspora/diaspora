def mock_private_keys_for_retraction(entity_name, entity, sender)
  if %i(signed_retraction_entity relayable_retraction_entity).include?(entity_name)
    allow(DiasporaFederation.callbacks).to receive(:trigger)
                                             .with(:fetch_private_key_by_diaspora_id, sender.diaspora_handle)
                                             .and_return(sender.encryption_key)
  end
  if entity_name == :relayable_retraction_entity
    allow(DiasporaFederation.callbacks).to receive(:trigger)
                                             .with(
                                               :fetch_entity_author_id_by_guid,
                                               entity.target_type,
                                               entity.target_guid
                                             )
                                             .and_return(sender.encryption_key)
  end
end

def generate_retraction(entity_name, target_object, sender)
  entity = FactoryGirl.build(
    entity_name,
    diaspora_id: sender.diaspora_handle,
    target_guid: target_object.guid,
    target_type: target_object.class.to_s
  )

  mock_private_keys_for_retraction(entity_name, entity, sender)
  generate_xml(entity, sender, alice)
end

shared_examples_for "it retracts non-relayable object" do
  it_behaves_like "it retracts object" do
    let(:sender) { remote_user_on_pod_b }
  end

  it "doesn't retract object when sender is different from target object" do
    target_klass = target_object.class.to_s.constantize
    Workers::ReceiveEncryptedSalmon.new.perform(
      alice.id,
      generate_retraction(entity_name, target_object, remote_user_on_pod_c)
    )

    expect(target_klass.exists?(guid: target_object.guid)).to be(true)
  end
end

shared_examples_for "it retracts object" do
  it "retracts object by a correct message" do
    target_klass = target_object.class.to_s.constantize
    Workers::ReceiveEncryptedSalmon.new.perform(alice.id, generate_retraction(entity_name, target_object, sender))

    expect(target_klass.exists?(guid: target_object.guid)).to be(false)
  end

  it "doesn't retract object when retraction has wrong signatures" do
    target_klass = target_object.class.to_s.constantize

    allow(sender).to receive(:encryption_key).and_return(OpenSSL::PKey::RSA.new(1024))

    Workers::ReceiveEncryptedSalmon.new.perform(alice.id, generate_retraction(entity_name, target_object, sender))

    expect(target_klass.exists?(guid: target_object.guid)).to be(true)
  end
end
