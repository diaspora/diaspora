shared_examples_for "it deals correctly with a relayable" do
  it "treats upstream receive correctly" do
    Workers::ReceiveEncryptedSalmon.new.perform(@user.id, generate_relayable_local_parent(entity_name))
    received_entity = klass.find_by(guid: @entity.guid)
    expect(received_entity).not_to be_nil
    expect(received_entity.author.diaspora_handle).to eq(@remote_person.diaspora_handle)
  end

  it "rejects an upstream entity with a malformed author signature" do
    Workers::ReceiveEncryptedSalmon.new.perform(
      @user.id,
      generate_relayable_local_parent_wrong_author_key(entity_name)
    )
    expect(klass.exists?(guid: @entity.guid)).to be(false)
  end

  it "treats downstream receive correctly" do
    Workers::ReceiveEncryptedSalmon.new.perform(@user.id, generate_relayable_remote_parent(entity_name))
    received_entity = klass.find_by(guid: @entity.guid)
    expect(received_entity).not_to be_nil
    expect(received_entity.author.diaspora_handle).to eq(@remote_person2.diaspora_handle)
  end

  it "rejects a downstream entity with a malformed author signature" do
    Workers::ReceiveEncryptedSalmon.new.perform(
      @user.id,
      generate_relayable_remote_parent_wrong_author_key(entity_name)
    )
    expect(klass.exists?(guid: @entity.guid)).to be(false)
  end

  it "declines downstream receive when sender signed with a wrong key" do
    Workers::ReceiveEncryptedSalmon.new.perform(
      @user.id,
      generate_relayable_remote_parent_wrong_parent_key(entity_name)
    )
    expect(klass.exists?(guid: @entity.guid)).to be(false)
  end
end
