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

  Fabricate(
    entity_name,
    parent_guid:      parent.guid,
    author:           diaspora_id,
    poll_answer_guid: parent.respond_to?(:poll_answers) ? parent.poll_answers.first.guid : nil,
    parent:           Diaspora::Federation::Entities.related_entity(parent)
  )
end

def generate_payload(entity, remote_user, recipient=nil)
  magic_env = DiasporaFederation::Salmon::MagicEnvelope.new(
    entity,
    remote_user.diaspora_handle
  ).envelop(remote_user.encryption_key)

  if recipient
    DiasporaFederation::Salmon::EncryptedMagicEnvelope.encrypt(magic_env, recipient.encryption_key)
  else
    magic_env.to_xml
  end
end

def post_message(payload, recipient=nil)
  if recipient
    inlined_jobs do
      headers = {"CONTENT_TYPE" => "application/json"}
      post "/receive/users/#{recipient.guid}", payload, headers
    end
  else
    inlined_jobs do
      headers = {"CONTENT_TYPE" => "application/magic-envelope+xml"}
      post "/receive/public", payload, headers
    end
  end
end
