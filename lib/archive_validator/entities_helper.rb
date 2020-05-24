# frozen_string_literal: true

class ArchiveValidator
  module EntitiesHelper
    private

    def instance
      @instance ||= model_class.find_by(guid: guid)
    end

    def entity_type
      json.fetch("entity_type")
    end

    def entity_data
      json.fetch("entity_data")
    end

    def model_class
      @model_class ||= Diaspora::Federation::Mappings.model_class_for(entity_type.camelize)
    end

    def entity_class
      DiasporaFederation::Entity.entity_class(entity_type)
    end

    def guid
      @guid ||= entity_data.fetch("guid")
    end

    def to_s
      "#{entity_class.class_name}:#{guid}"
    end
  end
end
