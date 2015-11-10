# configure the federation engine
DiasporaFederation.configure do |config|
  # the pod url
  config.server_uri = AppConfig.pod_uri

  config.certificate_authorities = AppConfig.environment.certificate_authorities.get

  config.define_callbacks do
    on :fetch_person_for_webfinger do |handle|
      person = Person.find_local_by_diaspora_handle(handle)
      person.webfinger if person
    end

    on :fetch_person_for_hcard do |guid|
      person = Person.find_local_by_guid(guid)
      person.hcard if person
    end

    on :save_person_after_webfinger do |person|
      # find existing person or create a new one
      person_entity = Person.find_by(diaspora_handle: person.diaspora_id) ||
        Person.new(diaspora_handle: person.diaspora_id, guid: person.guid,
                   serialized_public_key: person.exported_key, url: person.url)

      profile = person.profile
      profile_entity = person_entity.profile ||= Profile.new

      # fill or update profile
      profile_entity.first_name = profile.first_name
      profile_entity.last_name = profile.last_name
      profile_entity.image_url = profile.image_url
      profile_entity.image_url_medium = profile.image_url_medium
      profile_entity.image_url_small = profile.image_url_small
      profile_entity.searchable = profile.searchable

      person_entity.save!
    end

    on :fetch_private_key_by_diaspora_id do |diaspora_id|
      key = Person.where(diaspora_handle: diaspora_id).joins(:owner).pluck(:serialized_private_key).first
      OpenSSL::PKey::RSA.new key unless key.nil?
    end

    on :fetch_author_private_key_by_entity_guid do |entity_type, guid|
      key = entity_type.constantize.where(guid: guid).joins(author: :owner).pluck(:serialized_private_key).first
      OpenSSL::PKey::RSA.new key unless key.nil?
    end

    on :fetch_public_key_by_diaspora_id do |diaspora_id|
      key = Person.where(diaspora_handle: diaspora_id).pluck(:serialized_public_key).first
      OpenSSL::PKey::RSA.new key unless key.nil?
    end

    on :fetch_author_public_key_by_entity_guid do |entity_type, guid|
      key = entity_type.constantize.where(guid: guid).joins(:author).pluck(:serialized_public_key).first
      OpenSSL::PKey::RSA.new key unless key.nil?
    end

    on :entity_author_is_local? do |entity_type, guid|
      entity_type.constantize.where(guid: guid).joins(author: :owner).exists?
    end

    on :fetch_entity_author_id_by_guid do |entity_type, guid|
      entity_type.constantize.where(guid: guid).joins(:author).pluck(:diaspora_handle).first
    end
  end
end
