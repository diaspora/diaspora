module AMS
  module V09
    class Serializer < ActiveModel::Serializer

       def serializable_hash(adapter_options = nil,
                             options = {},
                             adapter_instance = self.class.serialization_adapter_instance)
         object.nil? ? nil : super
       end
    end

    class ArraySerializer < ActiveModel::Serializer::CollectionSerializer
    end

    class ResourceIdentifier < ActiveModelSerializers::Adapter::JsonApi::ResourceIdentifier

      def initialize(serializer, options)
        @id   = id_for(serializer)
        @type = type_for(serializer)
      end

    private

      def id_for(serializer)
        serializer.read_attribute_for_serialization(:id)
      end

    end

    class Base < ActiveModelSerializers::Adapter::Base

      def initialize(serializer, options = {})
        super
        @fieldset = options[:fieldset] || ActiveModel::Serializer::Fieldset.new(options.delete(:fields))
      end

    private

      attr_reader :fieldset

      def attributes_for(serializer, fields)
        serializer.attributes(fields).except(:id)
      end

      def resource_object_for(serializer)
        resource_object = serializer.fetch(self) do
          resource_object = ResourceIdentifier.new(serializer, instance_options).as_json

          requested_fields = fieldset && fieldset.fields_for(resource_object[:type])
          attributes = attributes_for(serializer, requested_fields)
          resource_object.merge!(attributes) if attributes.any?
          resource_object
        end

        resource_object
      end

    end

    # represent resource without associations
    class Attributes < Base

      def serializable_hash(options = nil)
        return nil if serializer.nil? || serializer.object.nil?

        is_collection = serializer.respond_to?(:each)
        serializers = is_collection ? serializer : [serializer]
        data = resource_objects_for(serializers)

        result = is_collection ? data : data[0]

        self.class.transform_key_casing!(result, instance_options)
      end

    private

      def resource_objects_for(serializers)
        serializers.map { |serializer| resource_object_for(serializer) }
      end

    end

    class AttributesWithIncluded < Base

      def serializable_hash(options = nil)
        return {} if serializer.object.nil?

        is_collection = serializer.respond_to?(:each)
        serializers = is_collection ? serializer : [serializer]
        primary_data, included = resource_objects_for(serializers)

        hash = {}
        hash[root] = is_collection ? primary_data : primary_data[0]
        hash[:included] = included if included.any?
        hash[meta_key] = meta unless meta.blank?

        self.class.transform_key_casing!(hash, instance_options)
      end

    private

      def resource_objects_for(serializers)
        @primary = []
        @included = {}
        @resource_identifiers = Set.new
        serializers.each { |serializer| process_resource(serializer) }
        serializers.each { |serializer| process_relationships(serializer) }

        [@primary, @included]
      end

      def process_resource(serializer)
        return false unless resource_already_processed?(serializer)

        @primary << resource_object_for(serializer)
        true
      end

      def process_relationship_resource(serializer, json_key)
        return false unless resource_already_processed?(serializer)

        @included[json_key] << resource_object_for(serializer)
        true
      end

      def process_relationships(serializer)
        serializer.associations.each do |association|
          process_relationship(association.serializer, association.key)
        end
      end

      def process_relationship(serializer, key)
        json_key = key || serializer.json_key.to_s.pluralize
        @included[json_key] ||= []

        if serializer.respond_to?(:each)
          serializer.each { |s| process_relationship(s, key) }
          return
        end
        return unless serializer && serializer.object
        return unless process_relationship_resource(serializer, json_key)

        process_relationships(serializer)
      end

      def resource_already_processed?(serializer)
        resource_identifier = ResourceIdentifier.new(serializer, instance_options).as_json
        @resource_identifiers.add?(resource_identifier)
      end

      def meta
        instance_options.fetch(:meta, nil)
      end

      def meta_key
        instance_options.fetch(:meta_key, 'meta'.freeze)
      end

    end

  end
end

ActiveModelSerializers::Adapter.register :v09_attributes_with_included, AMS::V09::AttributesWithIncluded
ActiveModelSerializers::Adapter.register :v09_attributes, AMS::V09::Attributes
ActiveModelSerializers.config.adapter = :v09_attributes_with_included
