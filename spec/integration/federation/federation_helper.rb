# frozen_string_literal: true

def remote_user_on_pod_b
  @remote_on_b ||= create_remote_user("remote-b.net")
end

def remote_user_on_pod_c
  @remote_on_c ||= create_remote_user("remote-c.net")
end

def allow_private_key_fetch(user)
  allow(DiasporaFederation.callbacks).to receive(:trigger).with(
    :fetch_private_key, user.diaspora_handle
  ) { user.encryption_key }
end

def allow_public_key_fetch(user)
  allow(DiasporaFederation.callbacks).to receive(:trigger).with(
    :fetch_public_key, user.diaspora_handle
  ) { OpenSSL::PKey::RSA.new(user.person.serialized_public_key) }
end

def create_undiscovered_user(pod)
  FactoryGirl.build(:user).tap do |user|
    allow(user).to receive(:person).and_return(
      FactoryGirl.build(:person,
                        profile:               FactoryGirl.build(:profile),
                        serialized_public_key: user.encryption_key.public_key.export,
                        pod:                   Pod.find_or_create_by(url: "http://#{pod}"),
                        diaspora_handle:       "#{user.username}@#{pod}")
    )
  end
end

def expect_person_discovery(undiscovered_user)
  allow(Person).to receive(:find_or_fetch_by_identifier).with(any_args).and_call_original
  expect(Person).to receive(:find_or_fetch_by_identifier).with(undiscovered_user.diaspora_handle) {
    undiscovered_user.person.save!
    undiscovered_user.person
  }
end

def create_remote_user(pod)
  create_undiscovered_user(pod).tap do |user|
    user.person.save!
    allow_private_key_fetch(user)
    allow_public_key_fetch(user)
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

def create_account_migration_entity(diaspora_id, new_user)
  Fabricate(
    :account_migration_entity,
    author:  diaspora_id,
    profile: Diaspora::Federation::Entities.build(new_user.profile)
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
      post "/receive/users/#{recipient.guid}", params: payload, headers: headers
    end
  else
    inlined_jobs do
      headers = {"CONTENT_TYPE" => "application/magic-envelope+xml"}
      post "/receive/public", params: payload, headers: headers
    end
  end
end
