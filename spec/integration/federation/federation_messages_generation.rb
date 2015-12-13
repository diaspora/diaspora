def generate_xml(entity, remote_user, user)
  DiasporaFederation::Salmon::EncryptedSlap.generate_xml(
    remote_user.diaspora_handle,
    OpenSSL::PKey::RSA.new(remote_user.encryption_key),
    entity,
    OpenSSL::PKey::RSA.new(user.encryption_key)
  )
end

def generate_status_message
  @entity = FactoryGirl.build(
    :status_message_entity,
    diaspora_id: @remote_user.diaspora_handle,
    public:      false
  )

  generate_xml(@entity, @remote_user, @user)
end

def generate_forged_status_message
  substitute_wrong_key(@remote_user, 1)
  generate_status_message
end

def mock_private_key_for_user(user)
  expect(DiasporaFederation.callbacks).to receive(:trigger)
                                            .with(:fetch_private_key_by_diaspora_id, user.person.diaspora_handle)
                                            .once
                                            .and_return(user.encryption_key)
end

def retraction_mock_callbacks(entity, sender)
  return unless [
    DiasporaFederation::Entities::SignedRetraction,
    DiasporaFederation::Entities::RelayableRetraction
  ].include?(entity.class)

  mock_private_key_for_user(sender)

  allow(DiasporaFederation.callbacks).to receive(:trigger)
                                            .with(
                                              :fetch_entity_author_id_by_guid,
                                              entity.target_type,
                                              entity.target_guid
                                            )
                                            .once
                                            .and_return(sender.encryption_key)
end

def generate_retraction(entity_name, target_object, sender=@remote_user)
  @entity = FactoryGirl.build(
    entity_name,
    diaspora_id: sender.diaspora_handle,
    target_guid: target_object.guid,
    target_type: target_object.class.to_s
  )

  retraction_mock_callbacks(@entity, sender)

  generate_xml(@entity, sender, @user)
end

def generate_forged_retraction(entity_name, target_object, sender=@remote_user)
  times = 1
  if %i(signed_retraction_entity relayable_retraction_entity).include?(entity_name)
    times += 2
  end

  substitute_wrong_key(sender, times)
  generate_retraction(entity_name, target_object, sender)
end

def generate_relayable_local_parent(entity_name)
  @entity = FactoryGirl.build(
    entity_name,
    parent_guid: @local_message.guid,
    diaspora_id: @remote_user.person.diaspora_handle
  )

  mock_private_key_for_user(@remote_user)

  expect(DiasporaFederation.callbacks).to receive(:trigger)
                                            .with(:fetch_author_private_key_by_entity_guid, "Post", kind_of(String))
                                            .and_return(nil)
  generate_xml(@entity, @remote_user, @user)
end

def generate_relayable_remote_parent(entity_name)
  @entity = FactoryGirl.build(
    entity_name,
    parent_guid: @remote_message.guid,
    diaspora_id: @remote_user2.person.diaspora_handle
  )

  mock_private_key_for_user(@remote_user2)

  expect(DiasporaFederation.callbacks).to receive(:trigger)
                                            .with(
                                              :fetch_author_private_key_by_entity_guid,
                                              "Post",
                                              @remote_message.guid
                                            )
                                            .once
                                            .and_return(@remote_user.encryption_key)
  generate_xml(@entity, @remote_user, @user)
end

def substitute_wrong_key(user, times_number)
  expect(user).to receive(:encryption_key).exactly(times_number).times.and_return(
    OpenSSL::PKey::RSA.new(1024)
  )
end

# Checks when a remote pod wants to send us a relayable without having a key for declared diaspora ID
def generate_relayable_local_parent_wrong_author_key(entity_name)
  substitute_wrong_key(@remote_user, 2)
  generate_relayable_local_parent(entity_name)
end

# Checks when a remote pod B wants to send us a relayable with authorship from a remote pod C user
# without having correct signature from him.
def generate_relayable_remote_parent_wrong_author_key(entity_name)
  substitute_wrong_key(@remote_user2, 1)
  generate_relayable_remote_parent(entity_name)
end

# Checks when a remote pod C wants to send us a relayable from its user, but bypassing the pod B where
# remote status came from.
def generate_relayable_remote_parent_wrong_parent_key(entity_name)
  substitute_wrong_key(@remote_user, 2)
  generate_relayable_remote_parent(entity_name)
end
