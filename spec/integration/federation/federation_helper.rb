def remote_user_on_pod_b
  @remote_on_b ||= FactoryGirl.build(:user).tap do |user|
    user.person = FactoryGirl.create(:person,
                                     profile:               FactoryGirl.build(:profile),
                                     serialized_public_key: user.encryption_key.public_key.export,
                                     diaspora_handle:       "#{user.username}@remote-b.net")
  end
end

def remote_user_on_pod_c
  @remote_on_c ||= FactoryGirl.build(:user).tap do |user|
    user.person = FactoryGirl.create(:person,
                                     profile:               FactoryGirl.build(:profile),
                                     serialized_public_key: user.encryption_key.public_key.export,
                                     diaspora_handle:       "#{user.username}@remote-c.net")
  end
end

def generate_xml(entity, remote_user, user)
  DiasporaFederation::Salmon::EncryptedSlap.generate_xml(
    remote_user.diaspora_handle,
    OpenSSL::PKey::RSA.new(remote_user.encryption_key),
    entity,
    OpenSSL::PKey::RSA.new(user.encryption_key)
  )
end
