shared_examples_for "it retracts non-relayable object" do
  it "retracts object by a correct retraction message" do
    target_klass = target_object.class.to_s.constantize
    Workers::ReceiveEncryptedSalmon.new.perform(@user.id, generate_retraction(entity_name, target_object))

    expect(target_klass.exists?(guid: target_object.guid)).to be(false)
  end

  it "doesn't retract object when retraction has wrong signatures" do
    target_klass = target_object.class.to_s.constantize
    Workers::ReceiveEncryptedSalmon.new.perform(@user.id, generate_forged_retraction(entity_name, target_object))

    expect(target_klass.exists?(guid: target_object.guid)).to be(true)
  end

  it "doesn't retract object when sender is different from target object" do
    target_klass = target_object.class.to_s.constantize
    Workers::ReceiveEncryptedSalmon.new.perform(
      @user.id,
      generate_retraction(entity_name, target_object, @remote_user2)
    )

    expect(target_klass.exists?(guid: target_object.guid)).to be(true)
  end
end

shared_examples_for "it retracts relayable object" do
  it "retracts object by a correct message" do
    target_klass = target_object.class.to_s.constantize
    Workers::ReceiveEncryptedSalmon.new.perform(@user.id, generate_retraction(entity_name, target_object, sender))

    expect(target_klass.exists?(guid: target_object.guid)).to be(false)
  end

  it "doesn't retract object when retraction has wrong signatures" do
    target_klass = target_object.class.to_s.constantize
    Workers::ReceiveEncryptedSalmon.new.perform(
      @user.id,
      generate_forged_retraction(entity_name, target_object, sender)
    )

    expect(target_klass.exists?(guid: target_object.guid)).to be(true)
  end
end
