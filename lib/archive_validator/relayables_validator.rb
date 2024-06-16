# frozen_string_literal: true

class ArchiveValidator
  class RelayablesValidator < CollectionValidator
    def collection
      relayables
    end

    def entity_validator
      OwnRelayableValidator
    end
  end
end
