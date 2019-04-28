# frozen_string_literal: true

class ArchiveValidator
  class ContactValidator < BaseValidator
    def initialize(archive_hash, contact)
      @contact = contact
      super(archive_hash)
    end

    private

    def validate
      handle_migrant_contact
      self.valid = account_open?
    rescue DiasporaFederation::Discovery::DiscoveryError => e
      messages.push("#{self.class}: failed to fetch person #{diaspora_id}: #{e}")
      self.valid = false
    end

    attr_reader :contact

    def diaspora_id
      contact.fetch("account_id")
    end

    def handle_migrant_contact
      return if person.account_migration.nil?

      contact["account_id"] = person.account_migration.newest_person.diaspora_handle
      @person = nil
    end

    def person
      @person ||= Person.find_or_fetch_by_identifier(diaspora_id)
    end

    def account_open?
      !person.closed_account? || (messages.push("#{self.class}: account #{diaspora_id} is closed") && false)
    end
  end
end
