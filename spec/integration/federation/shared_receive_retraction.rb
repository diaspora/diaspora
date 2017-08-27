# frozen_string_literal: true

def retraction_entity(target_object, sender)
  Fabricate(
    :retraction_entity,
    author:      sender.diaspora_handle,
    target_guid: target_object.guid,
    target_type: target_object.class.to_s,
    target:      Diaspora::Federation::Entities.related_entity(target_object)
  )
end

shared_examples_for "it retracts non-relayable object" do
  it "retracts object by a correct retraction message" do
    entity = retraction_entity(target_object, sender)
    post_message(generate_payload(entity, sender, recipient), recipient)

    expect(target_object.class.exists?(guid: target_object.guid)).to be_falsey
  end

  it "doesn't retract object when retraction has wrong signatures" do
    allow(sender).to receive(:encryption_key).and_return(OpenSSL::PKey::RSA.new(1024))
    entity = retraction_entity(target_object, sender)
    post_message(generate_payload(entity, sender, recipient), recipient)

    expect(target_object.class.exists?(guid: target_object.guid)).to be_truthy
  end

  it "doesn't retract object when sender is different from target object" do
    entity = retraction_entity(target_object, remote_user_on_pod_c)
    post_message(generate_payload(entity, remote_user_on_pod_c, recipient), recipient)

    expect(target_object.class.exists?(guid: target_object.guid)).to be_truthy
  end
end

shared_examples_for "it retracts relayable object" do
  it "retracts object by a correct message" do
    entity = retraction_entity(target_object, sender)
    post_message(generate_payload(entity, sender, recipient), recipient)

    expect(target_object.class.exists?(guid: target_object.guid)).to be_falsey
  end

  it "doesn't retract object when retraction has wrong signatures" do
    allow(sender).to receive(:encryption_key).and_return(OpenSSL::PKey::RSA.new(1024))
    entity = retraction_entity(target_object, sender)
    post_message(generate_payload(entity, sender, recipient), recipient)

    expect(target_object.class.exists?(guid: target_object.guid)).to be_truthy
  end
end
