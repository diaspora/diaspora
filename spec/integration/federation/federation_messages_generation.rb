def generate_profile
  @entity = FactoryGirl.build(:profile_entity, diaspora_id: remote_user_on_pod_b.person.diaspora_handle)

  generate_xml(@entity, remote_user_on_pod_b, alice)
end

def generate_conversation
  @entity = FactoryGirl.build(
    :conversation_entity,
    diaspora_id:     remote_user_on_pod_b.diaspora_handle,
    participant_ids: "#{remote_user_on_pod_b.diaspora_handle};#{alice.diaspora_handle}"
  )

  generate_xml(@entity, remote_user_on_pod_b, alice)
end

def generate_status_message
  @entity = FactoryGirl.build(
    :status_message_entity,
    diaspora_id: remote_user_on_pod_b.diaspora_handle,
    public:      @public
  )

  generate_xml(@entity, remote_user_on_pod_b, alice)
end

def generate_forged_status_message
  substitute_wrong_key(remote_user_on_pod_b, 1)
  generate_status_message
end

def generate_reshare
  @entity = FactoryGirl.build(
    :reshare_entity,
    root_diaspora_id: alice.diaspora_handle,
    root_guid:        @local_target.guid,
    diaspora_id:      remote_user_on_pod_b.diaspora_handle,
    public:           true
  )

  generate_xml(@entity, remote_user_on_pod_b, alice)
end

def mock_private_key_for_user(user)
  expect(DiasporaFederation.callbacks).to receive(:trigger)
                                            .with(:fetch_private_key_by_diaspora_id, user.person.diaspora_handle)
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
                                            .and_return(sender.encryption_key)
end

def generate_retraction(entity_name, target_object, sender=remote_user_on_pod_b)
  @entity = FactoryGirl.build(
    entity_name,
    diaspora_id: sender.diaspora_handle,
    target_guid: target_object.guid,
    target_type: target_object.class.to_s
  )

  retraction_mock_callbacks(@entity, sender)

  generate_xml(@entity, sender, alice)
end

def generate_forged_retraction(entity_name, target_object, sender=remote_user_on_pod_b)
  times = 1
  if %i(signed_retraction_entity relayable_retraction_entity).include?(entity_name)
    times += 2
  end

  substitute_wrong_key(sender, times)
  generate_retraction(entity_name, target_object, sender)
end

def generate_relayable_entity(entity_name, target, diaspora_id)
  @entity = FactoryGirl.build(
    entity_name,
    conversation_guid: target.guid,
    parent_guid:       target.guid,
    diaspora_id:       diaspora_id,
    poll_answer_guid:  target.respond_to?(:poll_answers) ? target.poll_answers.first.guid : nil
  )
end

def mock_entity_author_private_key_unavailable(klass)
  expect(DiasporaFederation.callbacks).to receive(:trigger)
                                            .with(
                                              :fetch_author_private_key_by_entity_guid,
                                              klass.get_target_entity_type(@entity.to_h),
                                              kind_of(String)
                                            )
                                            .and_return(nil)
end

def mock_entity_author_private_key_as(klass, key)
  expect(DiasporaFederation.callbacks).to receive(:trigger)
                                            .with(
                                              :fetch_author_private_key_by_entity_guid,
                                              klass.get_target_entity_type(@entity.to_h),
                                              @remote_target.guid
                                            )
                                            .and_return(key)
end

def generate_relayable_local_parent(entity_name)
  klass = FactoryGirl.factory_by_name(entity_name).build_class
  generate_relayable_entity(entity_name, @local_target, remote_user_on_pod_b.person.diaspora_handle)

  mock_private_key_for_user(remote_user_on_pod_b)
  mock_entity_author_private_key_unavailable(klass)

  generate_xml(@entity, remote_user_on_pod_b, alice)
end

def generate_relayable_remote_parent(entity_name)
  klass = FactoryGirl.factory_by_name(entity_name).build_class
  generate_relayable_entity(entity_name, @remote_target, remote_user_on_pod_c.person.diaspora_handle)

  mock_private_key_for_user(remote_user_on_pod_c)
  mock_entity_author_private_key_as(klass, remote_user_on_pod_b.encryption_key)

  generate_xml(@entity, remote_user_on_pod_b, alice)
end

def substitute_wrong_key(user, times_number)
  expect(user).to receive(:encryption_key).exactly(times_number).times.and_return(
    OpenSSL::PKey::RSA.new(1024)
  )
end

# Checks when a remote pod wants to send us a relayable without having a key for declared diaspora ID
def generate_relayable_local_parent_wrong_author_key(entity_name)
  substitute_wrong_key(remote_user_on_pod_b, 2)
  generate_relayable_local_parent(entity_name)
end

# Checks when a remote pod B wants to send us a relayable with authorship from a remote pod C user
# without having correct signature from him.
def generate_relayable_remote_parent_wrong_author_key(entity_name)
  substitute_wrong_key(remote_user_on_pod_c, 1)
  generate_relayable_remote_parent(entity_name)
end

# Checks when a remote pod C wants to send us a relayable from its user, but bypassing the pod B where
# remote status came from.
def generate_relayable_remote_parent_wrong_parent_key(entity_name)
  substitute_wrong_key(remote_user_on_pod_b, 2)
  generate_relayable_remote_parent(entity_name)
end
