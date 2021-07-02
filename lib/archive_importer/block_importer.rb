# frozen_string_literal: true

class ArchiveImporter
  class BlockImporter
    include Diaspora::Logging
    attr_reader :json, :user

    def initialize(json, user)
      @json = json
      @user = user
    end

    def import
      p = Person.find_or_fetch_by_identifier(json)
      migrant_person = handle_migrant_person(p)
      user.blocks.create(person_id: migrant_person.id)
    rescue ActiveRecord::RecordInvalid,
           DiasporaFederation::Discovery::DiscoveryError => e
      logger.warn "#{self}: #{e}"
    end

    private

    def handle_migrant_person(person)
      return person if person.account_migration.nil?

      person.account_migration.newest_person
    end
  end
end
