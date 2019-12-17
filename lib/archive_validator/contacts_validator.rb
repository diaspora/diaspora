# frozen_string_literal: true

class ArchiveValidator
  class ContactsValidator < CollectionValidator
    def collection
      contacts
    end

    def entity_validator
      ContactValidator
    end
  end
end
