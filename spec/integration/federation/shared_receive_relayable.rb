shared_examples_for "it deals correctly with a relayable" do
  it "treats upstream receive correctly" do
    expect(Postzord::Dispatcher).to receive(:build).with(alice, kind_of(klass)).and_call_original
    post_message(alice.guid, generate_relayable_local_parent(entity_name))
    received_entity = klass.find_by(guid: @entity.guid)
    expect(received_entity).not_to be_nil
    expect(received_entity.author.diaspora_handle).to eq(remote_user_on_pod_b.person.diaspora_handle)
  end

  it "rejects an upstream entity with a malformed author signature" do
    expect(Postzord::Dispatcher).not_to receive(:build)
    post_message(
      alice.guid,
      generate_relayable_local_parent_wrong_author_key(entity_name)
    )
    expect(klass.exists?(guid: @entity.guid)).to be(false)
  end

  it "treats downstream receive correctly" do
    expect(Postzord::Dispatcher).to receive(:build).with(alice, kind_of(klass)).and_call_original unless @public
    post_message(alice.guid, generate_relayable_remote_parent(entity_name))
    received_entity = klass.find_by(guid: @entity.guid)
    expect(received_entity).not_to be_nil
    expect(received_entity.author.diaspora_handle).to eq(remote_user_on_pod_c.person.diaspora_handle)
  end

  it "rejects a downstream entity with a malformed author signature" do
    expect(Postzord::Dispatcher).not_to receive(:build)
    post_message(
      alice.guid,
      generate_relayable_remote_parent_wrong_author_key(entity_name)
    )
    expect(klass.exists?(guid: @entity.guid)).to be(false)
  end

  it "declines downstream receive when sender signed with a wrong key" do
    expect(Postzord::Dispatcher).not_to receive(:build)
    post_message(
      alice.guid,
      generate_relayable_remote_parent_wrong_parent_key(entity_name)
    )
    expect(klass.exists?(guid: @entity.guid)).to be(false)
  end
end
