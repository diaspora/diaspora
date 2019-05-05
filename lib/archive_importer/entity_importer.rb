# frozen_string_literal: true

class ArchiveImporter
  class EntityImporter
    include ArchiveValidator::EntitiesHelper
    include Diaspora::Logging

    def initialize(json, user)
      @json = json
      @user = user
    end

    def import
      self.persisted_object = Diaspora::Federation::Receive.perform(entity, skip_relaying: true)
    rescue DiasporaFederation::Entities::Signable::SignatureVerificationFailed,
           DiasporaFederation::Discovery::InvalidDocument,
           DiasporaFederation::Discovery::DiscoveryError,
           DiasporaFederation::Federation::Fetcher::NotFetchable,
           OwnRelayableImporter::NoParentError,
           ActiveRecord::RecordInvalid => e
      logger.warn "#{self}: #{e}"
      self.persisted_object = nil
    end

    attr_reader :json
    attr_reader :user
    attr_accessor :persisted_object

    def entity
      entity_class.from_json(json)
    end
  end
end
