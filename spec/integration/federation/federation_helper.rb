def remote_user_on_pod_b
  @remote_on_b ||= create_remote_user("remote-b.net")
end

def remote_user_on_pod_c
  @remote_on_c ||= create_remote_user("remote-c.net")
end

def create_remote_user(pod)
  FactoryGirl.build(:user).tap do |user|
    allow(user).to receive(:person).and_return(
      FactoryGirl.create(:person,
                         profile:               FactoryGirl.build(:profile),
                         serialized_public_key: user.encryption_key.public_key.export,
                         pod:                   Pod.find_or_create_by(url: "http://#{pod}"),
                         diaspora_handle:       "#{user.username}@#{pod}")
    )
    allow(DiasporaFederation.callbacks).to receive(:trigger).with(
      :fetch_private_key, user.diaspora_handle
    ) { user.encryption_key }
    allow(DiasporaFederation.callbacks).to receive(:trigger).with(
      :fetch_public_key, user.diaspora_handle
    ) { OpenSSL::PKey::RSA.new(user.person.serialized_public_key) }
  end
end

def allow_callbacks(callbacks)
  callbacks.each do |callback|
    allow(DiasporaFederation.callbacks).to receive(:trigger).with(callback, any_args).and_call_original
  end
end

def create_relayable_entity(entity_name, parent, diaspora_id)
  expect(DiasporaFederation.callbacks).to receive(:trigger).with(
    :fetch_private_key, alice.diaspora_handle
  ).at_least(1).times.and_return(nil) if parent == local_parent

  parent_guid = parent.guid
  FactoryGirl.build(
    entity_name,
    conversation_guid: parent_guid,
    parent_guid:       parent_guid,
    author:            diaspora_id,
    poll_answer_guid:  parent.respond_to?(:poll_answers) ? parent.poll_answers.first.guid : nil,
    parent:            Diaspora::Federation::Entities.related_entity(parent)
  )
end

def generate_xml(entity, remote_user, recipient=nil)
  if recipient
    DiasporaFederation::Salmon::EncryptedSlap.prepare(
      remote_user.diaspora_handle,
      remote_user.encryption_key,
      entity
    ).generate_xml(recipient.encryption_key)
  else
    DiasporaFederation::Salmon::Slap.generate_xml(
      remote_user.diaspora_handle,
      remote_user.encryption_key,
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
