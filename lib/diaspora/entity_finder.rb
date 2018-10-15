# frozen_string_literal: true

module Diaspora
  class EntityFinder
    def initialize(type, guid)
      @type = type
      @guid = guid
    end

    def class_name
      @class_name ||= DiasporaFederation::Entity.entity_class(type).to_s.rpartition("::").last
    end

    def find
      Diaspora::Federation::Mappings.model_class_for(class_name).find_by(guid: guid)
    end

    private

    attr_reader :type, :guid
  end
end
