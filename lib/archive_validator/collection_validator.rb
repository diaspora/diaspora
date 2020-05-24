# frozen_string_literal: true

class ArchiveValidator
  class CollectionValidator < BaseValidator
    # Runs validations over each element in collection and removes every element
    # which fails the validations. Any messages produced by the entity_validator are
    # concatenated to the messages of the CollectionValidator instance.
    def validate
      collection.keep_if do |item|
        subvalidator = entity_validator.new(archive_hash, item)
        messages.concat(subvalidator.messages)
        subvalidator.valid?
      end
    end
  end
end
