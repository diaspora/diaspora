def retraction_entity(entity_name, target_object, sender)
  allow(DiasporaFederation.callbacks).to receive(:trigger)
                                           .with(
                                             :fetch_entity_author_id_by_guid,
                                             target_object.class.to_s,
                                             target_object.guid
                                           )
                                           .and_return(sender.encryption_key)

  FactoryGirl.build(
    entity_name,
    diaspora_id: sender.diaspora_handle,
    target_guid: target_object.guid,
    target_type: target_object.class.to_s
  )
end

shared_examples_for "it retracts non-relayable object" do
  it "retracts object by a correct retraction message" do
    entity = retraction_entity(entity_name, target_object, sender)
    post_message(generate_xml(entity, sender, recipient), recipient)

    expect(target_object.class.exists?(guid: target_object.guid)).to be_falsey
  end

  it "doesn't retract object when retraction has wrong signatures" do
    allow(sender).to receive(:encryption_key).and_return(OpenSSL::PKey::RSA.new(1024))
    entity = retraction_entity(entity_name, target_object, sender)
    post_message(generate_xml(entity, sender, recipient), recipient)

    expect(target_object.class.exists?(guid: target_object.guid)).to be_truthy
  end

  it "doesn't retract object when sender is different from target object" do
    entity = retraction_entity(entity_name, target_object, remote_user_on_pod_c)
    post_message(generate_xml(entity, remote_user_on_pod_c, recipient), recipient)

    expect(target_object.class.exists?(guid: target_object.guid)).to be_truthy
  end
end

shared_examples_for "it retracts relayable object" do
  it "retracts object by a correct message" do
    entity = retraction_entity(entity_name, target_object, sender)
    post_message(generate_xml(entity, sender, recipient), recipient)

    expect(target_object.class.exists?(guid: target_object.guid)).to be_falsey
  end

  it "doesn't retract object when retraction has wrong signatures" do
    allow(sender).to receive(:encryption_key).and_return(OpenSSL::PKey::RSA.new(1024))
    entity = retraction_entity(entity_name, target_object, sender)
    post_message(generate_xml(entity, sender, recipient), recipient)

    expect(target_object.class.exists?(guid: target_object.guid)).to be_truthy
  end
end
