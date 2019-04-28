# frozen_string_literal: true

class ArchiveImporter
  module ArchiveHelper
    def posts
      @posts ||= archive_hash.fetch("user").fetch("posts", [])
    end

    def relayables
      @relayables ||= archive_hash.fetch("user").fetch("relayables", [])
    end

    def others_relayables
      @others_relayables ||= archive_hash.fetch("others_data", {}).fetch("relayables", [])
    end

    def post_subscriptions
      archive_hash.fetch("user").fetch("post_subscriptions", [])
    end

    def contacts
      archive_hash.fetch("user").fetch("contacts", [])
    end

    def contact_groups
      @contact_groups ||= archive_hash.fetch("user").fetch("contact_groups", [])
    end

    def archive_author_diaspora_id
      @archive_author_diaspora_id ||= archive_hash.fetch("user").fetch("profile").fetch("entity_data").fetch("author")
    end

    def person
      @person ||= Person.find_or_fetch_by_identifier(archive_author_diaspora_id)
    end

    def private_key
      OpenSSL::PKey::RSA.new(serialized_private_key)
    end

    def serialized_private_key
      archive_hash.fetch("user").fetch("private_key")
    end
  end
end
