# frozen_string_literal: true

# configure the federation engine
DiasporaFederation.configure do |config|
  # the pod url
  config.server_uri = AppConfig.pod_uri

  config.certificate_authorities = AppConfig.environment.certificate_authorities.get

  config.webfinger_http_fallback = Rails.env == "development"

  config.http_concurrency = AppConfig.settings.typhoeus_concurrency.to_i
  config.http_verbose = AppConfig.settings.typhoeus_verbose?

  config.define_callbacks do
    on :fetch_person_for_webfinger do |diaspora_id|
      person = Person.where(diaspora_handle: diaspora_id, closed_account: false).where.not(owner: nil).first
      if person
        DiasporaFederation::Discovery::WebFinger.new(
          {
            acct_uri:      "acct:#{person.diaspora_handle}",
            hcard_url:     AppConfig.url_to(DiasporaFederation::Engine.routes.url_helpers.hcard_path(person.guid)),
            seed_url:      AppConfig.pod_uri,
            profile_url:   person.profile_url,
            atom_url:      person.atom_url,
            salmon_url:    person.receive_url,
            subscribe_url: AppConfig.url_to("/people?q={uri}")
          },
          aliases: [AppConfig.url_to("/people/#{person.guid}")],
          links:   [
            {
              rel:  OpenIDConnect::Discovery::Provider::Issuer::REL_VALUE,
              href: Rails.application.routes.url_helpers.root_url
            }
          ]
        )
      end
    end

    on :fetch_person_for_hcard do |guid|
      person = Person.where(guid: guid, closed_account: false).where.not(owner: nil).take
      if person
        DiasporaFederation::Discovery::HCard.new(
          guid:             person.guid,
          nickname:         person.username,
          full_name:        "#{person.profile.first_name} #{person.profile.last_name}".strip,
          url:              AppConfig.pod_uri,
          photo_large_url:  person.image_url,
          photo_medium_url: person.image_url(size: :thumb_medium),
          photo_small_url:  person.image_url(size: :thumb_small),
          public_key:       person.serialized_public_key,
          searchable:       person.searchable,
          first_name:       person.profile.first_name,
          last_name:        person.profile.last_name
        )
      end
    end

    on :save_person_after_webfinger do |person|
      # find existing person or create a new one
      person_entity = Person.find_by(diaspora_handle: person.diaspora_id) ||
        Person.new(diaspora_handle: person.diaspora_id, guid: person.guid,
                   serialized_public_key: person.exported_key, pod: Pod.find_or_create_by(url: person.url))

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

    on :fetch_private_key do |diaspora_id|
      key = Person.where(diaspora_handle: diaspora_id).joins(:owner).pluck(:serialized_private_key).first
      OpenSSL::PKey::RSA.new(key) unless key.nil?
    end

    on :fetch_public_key do |diaspora_id|
      Person.find_or_fetch_by_identifier(diaspora_id).public_key
    end

    on :fetch_related_entity do |entity_type, guid|
      entity = Diaspora::Federation::Mappings.model_class_for(entity_type).find_by(guid: guid)
      Diaspora::Federation::Entities.related_entity(entity) if entity
    end

    on :queue_public_receive do |xml, legacy=false|
      Workers::ReceivePublic.perform_async(xml, legacy)
    end

    on :queue_private_receive do |guid, xml, legacy=false|
      person = Person.find_by_guid(guid)

      (person.present? && person.owner_id.present?).tap do |user_found|
        Workers::ReceivePrivate.perform_async(person.owner.id, xml, legacy) if user_found
      end
    end

    on :receive_entity do |entity, sender, recipient_id|
      Person.by_account_identifier(sender).pod.try(:schedule_check_if_needed)

      case entity
      when DiasporaFederation::Entities::AccountDeletion
        Diaspora::Federation::Receive.account_deletion(entity)
      when DiasporaFederation::Entities::Retraction
        Diaspora::Federation::Receive.retraction(entity, recipient_id)
      else
        persisted = Diaspora::Federation::Receive.perform(entity)
        Workers::ReceiveLocal.perform_async(persisted.class.to_s, persisted.id, [recipient_id].compact) if persisted
      end
    end

    on :fetch_public_entity do |entity_type, guid|
      entity = Diaspora::Federation::Mappings.model_class_for(entity_type).all_public.find_by(guid: guid)
      case entity
      when Post
        Diaspora::Federation::Entities.post(entity)
      when Poll
        Diaspora::Federation::Entities.status_message(entity.status_message)
      end
    end

    on :fetch_person_url_to do |diaspora_id, path|
      Person.find_or_fetch_by_identifier(diaspora_id).url_to(path)
    end

    on :update_pod do |url, status|
      pod = Pod.find_or_create_by(url: url)

      if status.is_a? Symbol
        pod.status = Pod::CURL_ERROR_MAP.fetch(status, :unknown_error)
        pod.error = "FederationError: #{status}"
      elsif status >= 200 && status < 300
        pod.status = :no_errors unless Pod.statuses[pod.status] == Pod.statuses[:version_failed]
      else
        pod.status = :http_failed
        pod.error = "FederationError: HTTP status code was: #{status}"
      end
      pod.update_offline_since

      pod.save
    end
  end
end
