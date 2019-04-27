# frozen_string_literal: true

class ArchiveValidator
  # We have to validate relayables before import because during import we'll not be able to fetch parent anymore
  # because parent author will point to ourselves.
  class RelayableValidator < BaseValidator
    include EntitiesHelper

    def initialize(archive_hash, relayable)
      @relayable = relayable
      super(archive_hash)
    end

    private

    def validate
      self.valid = parent_present?
    end

    attr_reader :relayable
    alias json relayable

    # Common methods used by subclasses:

    def missing_parent_message
      messages.push("Parent entity for #{self} is missing. Impossible to import, ignoring.")
    end

    def parent_present?
      parent.present? || (missing_parent_message && false)
    end

    def parent
      @parent ||= find_parent
    end

    def find_parent
      if entity_type == "poll_participation"
        post_find_by_poll_guid(parent_guid)
      else
        post_find_by_guid(parent_guid)
      end
    end

    def parent_guid
      entity_data.fetch("parent_guid")
    end

    def post_find_by_guid(guid)
      posts.find {|post|
        post.fetch("entity_data").fetch("guid") == guid
      }
    end

    def post_find_by_poll_guid(guid)
      posts.find {|post|
        post.fetch("entity_data").fetch("poll", nil)&.fetch("entity_data", nil)&.fetch("guid", nil) == guid
      }
    end
  end
end
