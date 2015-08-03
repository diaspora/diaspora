# configure the federation engine
DiasporaFederation.configure do |config|
  # the pod url
  config.server_uri = AppConfig.pod_uri

  config.certificate_authorities = AppConfig.environment.certificate_authorities.get

  config.define_callbacks do
    on :fetch_person_for_webfinger do |handle|
      person = Person.find_local_by_diaspora_handle(handle)
      if person
        DiasporaFederation::Discovery::WebFinger.new(
          acct_uri:    "acct:#{person.diaspora_handle}",
          alias_url:   AppConfig.url_to("/people/#{person.guid}"),
          hcard_url:   AppConfig.url_to(DiasporaFederation::Engine.routes.url_helpers.hcard_path(person.guid)),
          seed_url:    AppConfig.pod_uri,
          profile_url: person.profile_url,
          atom_url:    person.atom_url,
          salmon_url:  person.receive_url,
          guid:        person.guid,
          public_key:  person.serialized_public_key
        )
      end
    end

    on :fetch_person_for_hcard do |guid|
      person = Person.find_local_by_guid(guid)
      if person
        DiasporaFederation::Discovery::HCard.new(
          guid:             person.guid,
          nickname:         person.username,
          full_name:        "#{person.profile.first_name} #{person.profile.last_name}".strip,
          url:              AppConfig.pod_uri,
          photo_large_url:  person.image_url,
          photo_medium_url: person.image_url(:thumb_medium),
          photo_small_url:  person.image_url(:thumb_small),
          public_key:       person.serialized_public_key,
          searchable:       person.searchable,
          first_name:       person.profile.first_name,
          last_name:        person.profile.last_name
        )
      end
    end
  end
end
