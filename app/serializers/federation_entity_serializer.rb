# frozen_string_literal: true

# This is an ActiveModel::Serializer based class which uses DiasporaFederation::Entity JSON serialization
# features in order to serialize local DB objects. To determine a type of entity class to use the same routines
# are used as for federation messages generation.
class FederationEntitySerializer < ActiveModel::Serializer
  include SerializerPostProcessing

  private

  def modify_serializable_object(hash)
    hash.merge(entity.to_json)
  end

  def entity
    Diaspora::Federation::Entities.build(object)
  end
end
