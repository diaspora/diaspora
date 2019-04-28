# frozen_string_literal: true

class ArchiveImporter
  class PostImporter < OwnEntityImporter
    include Diaspora::Logging

    def import
      super
      import_subscriptions if persisted_object
    end

    private

    def substitute_author
      super
      return unless entity_type == "status_message"

      entity_data["photos"].each do |photo|
        photo["entity_data"]["author"] = user.diaspora_handle
      end
    end

    def import_subscriptions
      json.fetch("subscribed_users_ids", []).each do |diaspora_id|
        begin
          person = Person.find_or_fetch_by_identifier(diaspora_id)
          person = person.account_migration.newest_person unless person.account_migration.nil?
          next if person.closed_account?
          # TODO: unless person.nil? import subscription: subscription import is not supported yet
        rescue DiasporaFederation::Discovery::DiscoveryError
        end
      end
    end
  end
end
