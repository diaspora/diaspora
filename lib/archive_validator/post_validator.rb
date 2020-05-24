# frozen_string_literal: true

class ArchiveValidator
  class PostValidator < BaseValidator
    include EntitiesHelper

    def initialize(archive_hash, post)
      @json = post
      super(archive_hash)
    end

    private

    def validate
      return unless entity_type == "reshare" && entity_data["root_guid"].nil?

      messages.push("reshare #{self} doesn't have a root, ignored")
    end

    attr_reader :json
  end
end
