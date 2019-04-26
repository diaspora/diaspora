# frozen_string_literal: true

class ArchiveImporter
  class OwnRelayableImporter < OwnEntityImporter
    def entity
      fetch_parent(symbolized_entity_data)
      entity_class.new(symbolized_entity_data)
    end

    private

    def symbolized_entity_data
      @symbolized_entity_data ||= entity_data.slice(*entity_class.class_props.keys.map(&:to_s)).symbolize_keys
    end

    # Copied over from DiasporaFederation::Entities::Relayable
    def fetch_parent(data)
      type = data.fetch(:parent_type) {
        break entity_class::PARENT_TYPE if entity_class.const_defined?(:PARENT_TYPE)
      }
      entity = Diaspora::Federation::Mappings.model_class_for(type).find_by(guid: data.fetch(:parent_guid))
      data[:parent] = Diaspora::Federation::Entities.related_entity(entity)
    end
  end
end
