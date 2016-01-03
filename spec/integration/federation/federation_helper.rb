def remote_user_on_pod_b
  @remote_on_b ||= create_remote_user("remote-b.net")
end

def remote_user_on_pod_c
  @remote_on_c ||= create_remote_user("remote-c.net")
end

def create_remote_user(pod)
  FactoryGirl.build(:user).tap do |user|
    user.person = FactoryGirl.create(:person,
                                     profile:               FactoryGirl.build(:profile),
                                     serialized_public_key: user.encryption_key.public_key.export,
                                     diaspora_handle:       "#{user.username}@#{pod}")
    allow(DiasporaFederation.callbacks).to receive(:trigger)
                                             .with(:fetch_private_key_by_diaspora_id, user.diaspora_handle) {
                                             user.encryption_key
                                           }
  end
end

def create_relayable_entity(entity_name, target, diaspora_id, parent_author_key)
  target_entity_type = FactoryGirl.factory_by_name(entity_name).build_class.get_target_entity_type(@entity.to_h)
  expect(DiasporaFederation.callbacks).to receive(:trigger)
                                            .with(
                                              :fetch_author_private_key_by_entity_guid,
                                              target_entity_type,
                                              target.guid
                                            )
                                            .and_return(parent_author_key)

  FactoryGirl.build(
    entity_name,
    conversation_guid: target.guid,
    parent_guid:       target.guid,
    diaspora_id:       diaspora_id,
    poll_answer_guid:  target.respond_to?(:poll_answers) ? target.poll_answers.first.guid : nil
  )
end

def generate_xml(entity, remote_user, recipient=nil)
  if recipient
    DiasporaFederation::Salmon::EncryptedSlap.generate_xml(
      remote_user.diaspora_handle,
      OpenSSL::PKey::RSA.new(remote_user.encryption_key),
      entity,
      OpenSSL::PKey::RSA.new(recipient.encryption_key)
    )
  else
    DiasporaFederation::Salmon::Slap.generate_xml(
      remote_user.diaspora_handle,
      OpenSSL::PKey::RSA.new(remote_user.encryption_key),
      entity
    )
  end
end

def post_message(xml, recipient=nil)
  if recipient
    inlined_jobs do
      post "/receive/users/#{recipient.guid}", guid: recipient.guid, xml: xml
    end
  else
    inlined_jobs do
      post "/receive/public", xml: xml
    end
  end
end
