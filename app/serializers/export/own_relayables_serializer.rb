# frozen_string_literal: true

module Export
  # This is a serializer for the user's own relayables. We remove signature from the own relayables since it isn't
  # useful and takes space.
  class OwnRelayablesSerializer < FederationEntitySerializer
    private

    def modify_serializable_object(hash)
      super.tap {|hash|
        hash[:entity_data].delete(:author_signature)
      }
    end
  end
end
