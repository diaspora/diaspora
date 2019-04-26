# frozen_string_literal: true

class ArchiveValidator
  class SchemaValidator < BaseValidator
    JSON_SCHEMA = "lib/schemas/archive-format.json"

    def validate
      return if JSON::Validator.validate(JSON_SCHEMA, archive_hash)

      messages.push("Archive schema validation failed")
    end
  end
end
